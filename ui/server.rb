#!/usr/bin/env ruby
# frozen_string_literal: true

# Tiny local web UI for editing, running and testing the playground's Ruby files.
# Programs run in a real pseudo-terminal (PTY), so `gets`, Ctrl+C and IRB work
# interactively in the browser. Standard library only (needs Linux/WSL/macOS for PTY).
#
#   ruby ui/server.rb          then open http://localhost:4567
#   PORT=8080 ruby ui/server.rb

require "socket"
require "json"
require "uri"
require "rbconfig"
require "pty"
require "io/console"
require "securerandom"

ROOT      = File.expand_path("..", __dir__)
UI_DIR    = __dir__
HOST      = "127.0.0.1"
PORT      = (ENV["PORT"] || 4567).to_i
TEST_FILE = "ruby_tests.rb"
READ_ONLY = %w[ruby_solutions.rb].freeze
SYNC      = File.join(UI_DIR, "sync_output.rb") # unbuffered output so prompts appear before gets
STATUS    = { 200 => "OK", 400 => "Bad Request", 403 => "Forbidden", 404 => "Not Found" }.freeze

def ruby_files = Dir.children(ROOT).select { |f| f.end_with?(".rb") && File.file?(File.join(ROOT, f)) }.sort

def test_names
  File.read(File.join(ROOT, TEST_FILE), encoding: "UTF-8").scan(/^\s*def (test_\w+)/).flatten
rescue Errno::ENOENT
  []
end

def file_path!(name)
  raise ArgumentError, "Unknown file: #{name.inspect}" unless ruby_files.include?(name)

  File.join(ROOT, name)
end

def irb_command
  irb = File.join(RbConfig::CONFIG["bindir"], "irb")
  File.exist?(irb) ? [RbConfig.ruby, irb] : [RbConfig.ruby, "-S", "irb"]
end

def parse_test_results(output)
  plain = output.gsub(/\e\[[0-9;?]*[A-Za-z]/, "")
  plain.scan(/#(test_\w+) = [\d.]+ s = ([.FES])/).to_h do |name, mark|
    [name, { "." => "pass", "F" => "fail", "E" => "error", "S" => "skip" }[mark]]
  end
end

# One running program attached to a pseudo-terminal.
class Run
  RUNS = {} # rubocop:disable Style/MutableConstant -- registry of live runs, changed only under LOCK
  LOCK = Mutex.new

  attr_reader :id, :events

  def self.find(id) = LOCK.synchronize { RUNS[id] } || raise(ArgumentError, "That program is no longer running")

  # Only one program runs at a time: starting a new one stops the previous one.
  def self.start(command, env: {}, test: false, rows: 24, cols: 80)
    LOCK.synchronize do
      RUNS.each_value(&:stop)
      RUNS.delete_if { |_, r| r.finished? } # finished runs are kept until their output has been streamed
    end
    run = new(command, env, test, rows, cols)
    LOCK.synchronize { RUNS[run.id] = run }
    run
  end

  def initialize(command, env, test, rows, cols)
    @id = SecureRandom.hex(8)
    @test = test
    @events = Queue.new
    @transcript = +"".b
    @reader, @writer, @pid = PTY.spawn({ "TERM" => "xterm-256color" }.merge(env), *command, chdir: ROOT)
    resize(rows, cols)
    Thread.new { pump }
  end

  def self.forget(id) = LOCK.synchronize { RUNS.delete(id) }

  def finished? = @finished

  def write(data)
    @writer.write(data) unless @finished
  rescue IOError, Errno::EIO
    nil # the program already exited
  end

  def resize(rows, cols)
    @reader.winsize = [rows.to_i.clamp(5, 500), cols.to_i.clamp(20, 1000)]
  rescue StandardError
    nil
  end

  def stop
    Process.kill("KILL", -@pid) # PTY.spawn makes the child a process-group leader
  rescue StandardError
    nil
  end

  private

  def pump
    loop do
      chunk = @reader.readpartial(16_384)
      @transcript << chunk if @test
      @events << [:output, chunk]
    end
  rescue EOFError, Errno::EIO
    # The program closed the terminal (it exited).
  ensure
    status = begin
      Process.wait2(@pid).last
    rescue StandardError
      nil
    end
    results = @test ? parse_test_results(@transcript.force_encoding("UTF-8").scrub) : nil
    @events << [:exit, { code: status&.exitstatus, signal: status&.termsig, results: results }]
    @finished = true
    [@reader, @writer].each do |io|
      io.close
    rescue StandardError
      nil
    end
  end
end

def route(method, path, params, body)
  case [method, path]
  when ["GET", "/"]
    [200, "text/html; charset=utf-8", File.read(File.join(UI_DIR, "index.html"))]
  when ["GET", "/api/files"]
    json(files: ruby_files, read_only: READ_ONLY, tests: test_names, test_file: TEST_FILE)
  when ["GET", "/api/file"]
    json(name: params["name"], content: File.read(file_path!(params["name"]), encoding: "UTF-8"))
  when ["POST", "/api/file"]
    name = body["name"]
    raise ArgumentError, "#{name} is read-only" if READ_ONLY.include?(name)

    path = file_path!(name)
    content = body["content"].to_s
    content = content.gsub(/\r?\n/, "\r\n") if File.read(path, mode: "rb").include?("\r\n") # keep CRLF files as CRLF
    File.write(path, content, mode: "wb")
    json(saved: name)
  when ["POST", "/api/start"]
    size = { rows: body["rows"] || 24, cols: body["cols"] || 80 }
    case body["kind"]
    when "file"
      file_path!(body["name"])
      run = Run.start([RbConfig.ruby, "-r", SYNC, body["name"]], **size)
      json(id: run.id, command: "ruby #{body["name"]}")
    when "test"
      test = body["test"]
      raise ArgumentError, "Unknown test: #{test}" if test && !test_names.include?(test)

      args = [RbConfig.ruby, "-r", SYNC, TEST_FILE, "-v"] + (test ? ["-n", test] : [])
      env = body["solutions"] ? { "SOLUTIONS" => "1" } : {}
      run = Run.start(args, env: env, test: true, **size)
      json(id: run.id, command: "#{"SOLUTIONS=1 " if body["solutions"]}ruby #{TEST_FILE}#{" -n #{test}" if test}")
    when "irb"
      run = Run.start(irb_command, **size)
      json(id: run.id, command: "irb")
    else
      raise ArgumentError, "Unknown kind: #{body["kind"].inspect}"
    end
  when ["POST", "/api/input"]
    Run.find(body["id"]).write(body["data"].to_s)
    json(ok: true)
  when ["POST", "/api/resize"]
    Run.find(body["id"]).resize(body["rows"], body["cols"])
    json(ok: true)
  when ["POST", "/api/stop"]
    Run.find(body["id"]).stop
    json(ok: true)
  else
    [404, "application/json", JSON.generate(error: "Not found")]
  end
end

def json(data) = [200, "application/json", JSON.generate(data)]

# Streams a run's terminal output as newline-delimited JSON until the program exits.
def stream(client, run)
  client.write("HTTP/1.1 200 OK\r\nContent-Type: application/x-ndjson\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n")
  loop do
    type, payload = run.events.pop
    if type == :output
      client.puts(JSON.generate(o: [payload].pack("m0")))
    else
      client.puts(JSON.generate(exit: payload))
      Run.forget(run.id)
      break
    end
  end
rescue Errno::EPIPE, Errno::ECONNRESET, IOError
  run.stop # the browser tab went away
end

def handle(client)
  request_line = client.gets or return
  method, target = request_line.split
  headers = {}
  while (line = client.gets) && line != "\r\n"
    key, value = line.split(":", 2)
    headers[key.strip.downcase] = value.to_s.strip
  end
  raw_body = headers["content-length"] ? client.read(headers["content-length"].to_i).to_s.force_encoding("UTF-8") : ""

  path, query = target.to_s.split("?", 2)
  params = query ? URI.decode_www_form(query).to_h : {}

  status, type, payload =
    # The Host check blocks DNS rebinding; the custom header blocks cross-site requests from other websites.
    if !headers["host"].to_s.match?(/\A(localhost|127\.0\.0\.1)(:\d+)?\z/) ||
       (path.start_with?("/api/") && headers["x-playground"] != "1")
      [403, "text/plain", "Forbidden"]
    elsif method == "GET" && path == "/api/stream"
      begin
        return stream(client, Run.find(params["id"]))
      rescue ArgumentError => e
        [400, "application/json", JSON.generate(error: e.message)]
      end
    else
      begin
        route(method, path, params, raw_body.empty? ? {} : JSON.parse(raw_body))
      rescue ArgumentError, Errno::ENOENT, JSON::ParserError => e
        [400, "application/json", JSON.generate(error: e.message)]
      end
    end

  client.write("HTTP/1.1 #{status} #{STATUS[status]}\r\nContent-Type: #{type}\r\n" \
               "Content-Length: #{payload.bytesize}\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n")
  client.write(payload)
rescue StandardError => e
  warn "#{e.class}: #{e.message}"
  begin
    client.write("HTTP/1.1 500 Internal Server Error\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
  rescue StandardError
    nil
  end
ensure
  begin
    client.close
  rescue StandardError
    nil
  end
end

server = TCPServer.new(HOST, PORT)
puts "Ruby Playground UI running at http://localhost:#{PORT}  (Ctrl+C to stop)"
trap("INT") do
  puts "\nStopped."
  exit
end
loop { Thread.new(server.accept) { |client| handle(client) } }
