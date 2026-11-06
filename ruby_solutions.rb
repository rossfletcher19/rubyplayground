# Answer key for ruby_exercises.rb — explained in plain, simple words.
# Every line has a comment saying what it does, like you're explaining it to a kid.

# ---------------------------------------------------------------
# 1. Two Sum
#
# Examples:
#   two_sum([2, 7, 11, 15], 9) => [0, 1]
#   two_sum([3, 2, 4], 6)      => [1, 2]
#
# Big idea: As we walk through the numbers, we write each one down in a notebook.
# For every new number, we ask: "Is the number I need already in my notebook?"
# ---------------------------------------------------------------
def two_sum(nums, target)
  seen = {}                                  # An empty notebook. We'll write "number -> where I saw it".
  nums.each_with_index do |n, i|             # Look at each number (n) and its spot in line (i), one at a time.
    complement = target - n                  # Figure out what number would add with n to make the target.
    return [seen[complement], i] if seen.key?(complement) # Is that number in the notebook? Yes! Give back both spots.

    seen[n] = i                              # Not yet. Write this number and its spot in the notebook.
  end
  nil                                        # We looked at everything and found no pair. Give back "nothing".
end

# ---------------------------------------------------------------
# 2. Anagram check
#
# Examples:
#   anagram?("Listen", "Silent") => true
#   anagram?("abc", "abd")       => false
#
# Big idea: If two words use the exact same letters, putting the letters
# in ABC order makes them look identical.
# ---------------------------------------------------------------
def anagram?(a, b)
  a.downcase.chars.sort == b.downcase.chars.sort
  # downcase -> make every letter small, so "L" and "l" count as the same
  # chars    -> break the word into single letters: "cat" -> ["c", "a", "t"]
  # sort     -> put the letters in ABC order: ["a", "c", "t"]
  # ==       -> are the two lists of letters exactly the same? true or false
  #
  # Another way: count each letter in both words and compare the counts.
  #   a.downcase.chars.tally == b.downcase.chars.tally
end

# ---------------------------------------------------------------
# 3. Group anagrams
#
# Examples:
#   group_anagrams(%w[eat tea tan ate nat bat])
#     => [["eat", "tea", "ate"], ["tan", "nat"], ["bat"]]
#
# Big idea: Give every word a "name tag" made of its letters in ABC order.
# Words with the same name tag go in the same bucket.
# ---------------------------------------------------------------
def group_anagrams(words)
  words.group_by { |w| w.chars.sort.join } # Make a name tag for each word ("tea" -> "aet") and
       # drop words with the same tag into the same bucket.
       .values # Throw away the name tags. Just give back the buckets.
end

# ---------------------------------------------------------------
# 4. First unique character
#
# Examples:
#   first_unique_char("leetcode")     => 0
#   first_unique_char("loveleetcode") => 2
#   first_unique_char("aabb")         => -1
#
# Big idea: First count how many times each letter shows up.
# Then walk the word from the start and stop at the first letter that showed up once.
# ---------------------------------------------------------------
def first_unique_char(s)
  counts = s.chars.tally                     # Count each letter. "leet" -> {"l"=>1, "e"=>2, "t"=>1}
  s.each_char.with_index do |c, i|           # Walk through the word, letter (c) by letter, with its spot (i).
    return i if counts[c] == 1               # Did this letter show up only once? Then give back its spot. Done!
  end
  -1                                         # Every letter showed up more than once. -1 means "none found".
  # Another way: s.chars.index { |c| counts[c] == 1 } || -1
end

# ---------------------------------------------------------------
# 5. Valid brackets
#
# Examples:
#   valid_brackets?("()[]{}") => true
#   valid_brackets?("{[()]}") => true
#   valid_brackets?("(]")     => false
#   valid_brackets?("([)]")   => false
#
# Big idea: Think of a stack of plates. Every opening bracket is a plate we put
# on top. Every closing bracket must match the plate on top, and we take it off.
# ---------------------------------------------------------------
def valid_brackets?(s)
  pairs = { ")" => "(", "]" => "[", "}" => "{" } # A cheat sheet: each closer and the opener it goes with.
  stack = []                                 # Our empty stack of plates.
  s.each_char do |c|                         # Look at each character one at a time.
    if pairs.value?(c)                       # Is it an opener like ( [ { ?
      stack.push(c)                          # Put it on top of the stack.
    elsif pairs.key?(c)                      # Is it a closer like ) ] } ?
      return false unless stack.pop == pairs[c] # Take the top plate off. If it's not the right opener, it's broken!
    end
  end
  stack.empty? # At the end, the stack should be empty (everything got closed).
end

# ---------------------------------------------------------------
# 6. Top K frequent elements
#
# Examples:
#   top_k_frequent([1, 1, 1, 2, 2, 3], 2) => [1, 2]
#
# Big idea: Count how many times each number shows up, then pick the k biggest counts.
# ---------------------------------------------------------------
def top_k_frequent(nums, k)
  nums.tally                                 # Count each number: {1=>3, 2=>2, 3=>1}
      .max_by(k) { |_num, count| count }     # Pick the k pairs with the biggest counts: [[1, 3], [2, 2]]
      # (The _ in _num means "I don't use this one.")
      .map(&:first) # From each pair, keep only the number: [1, 2]
end

# ---------------------------------------------------------------
# 7. Palindrome
#
# Examples:
#   palindrome?("A man, a plan, a canal: Panama") => true
#   palindrome?("race a car")                     => false
#
# Big idea: Clean the text up, then check whether it reads the same backwards.
# ---------------------------------------------------------------
def palindrome?(s)
  clean = s.downcase.gsub(/[^a-z0-9]/, "")   # Make letters small, then erase anything that isn't a letter or number.
  clean == clean.reverse                     # Flip it backwards. Is it the same as before?
end

# ---------------------------------------------------------------
# 8. Run-length compression
#
# Examples:
#   compress("aaabccdddd") => "a3b1c2d4"
#   compress("")           => ""
#
# Big idea: Bunch up letters that are the same and next to each other,
# then write each letter followed by how many were in its bunch.
# ---------------------------------------------------------------
def compress(s)
  s.chars                                    # Break into letters: ["a","a","a","b","c","c"]
   .chunk_while { |a, b| a == b }            # Keep neighbors together while they match: [["a","a","a"], ["b"], ["c","c"]]
   .map { |run| "#{run.first}#{run.size}" }  # Turn each bunch into "letter + how many": ["a3", "b1", "c2"]
   .join                                     # Glue them into one string: "a3b1c2"
  # Another way, using a pattern: s.gsub(/(.)\1*/) { |m| "#{m[0]}#{m.size}" }
end

# ---------------------------------------------------------------
# 9. Maximum subarray sum (Kadane's algorithm)
#
# Examples:
#   max_subarray([-2, 1, -3, 4, -1, 2, 1, -5, 4]) => 6   ([4, -1, 2, 1])
#   max_subarray([-3, -1, -2])                    => -1
#
# Big idea: Walk along keeping a running total. If the running total ever hurts
# more than it helps, throw it away and start over from the current number.
# ---------------------------------------------------------------
def max_subarray(nums)
  best = current = nums.first                # Start both "best ever" and "running total" at the first number.
  nums.drop(1).each do |n|                   # Look at every number after the first one.
    current = [n, current + n].max           # Is it better to keep adding, or start fresh with just n? Pick the bigger.
    best = [best, current].max               # Is the running total our new record? If so, remember it.
  end
  best                                       # Give back the record.
end

# ---------------------------------------------------------------
# 10. Moving average
#
# Examples:
#   moving_average([1, 2, 3, 4, 5], 3) => [2.0, 3.0, 4.0]
#   moving_average([1, 2, 3], 2)       => [1.5, 2.5]
#
# Big idea: Slide a little window across the list and average what's inside each time.
# ---------------------------------------------------------------
def moving_average(nums, k)
  nums.each_cons(k)                          # Make windows of k numbers in a row: [1,2,3], [2,3,4], [3,4,5]
      .map { |w| w.sum.fdiv(k).round(2) }    # For each window: add it up, divide by k (keeping decimals), round to 2 places.
end

# ---------------------------------------------------------------
# 11. Merge overlapping intervals
#
# Examples:
#   merge_intervals([[1, 3], [8, 10], [2, 6], [15, 18]]) => [[1, 6], [8, 10], [15, 18]]
#   merge_intervals([[1, 4], [4, 5]])                   => [[1, 5]]
#
# Big idea: Line the time ranges up by start time. Then if a range starts before
# the last one ends, they touch, so stretch the last one instead of adding a new one.
# ---------------------------------------------------------------
def merge_intervals(intervals)
  intervals.sort_by(&:first) # Put the ranges in order by their start number.
           .each_with_object([]) do |(start, stop), merged| # Go through each range. Unpack it into start and stop.
    # merged is our answer list that we fill up as we go.
    if merged.any? && start <= merged.last[1] # Does this range start before the last saved range ends? They overlap!
      merged.last[1] = [merged.last[1], stop].max # Stretch the last saved range so it ends at the later stop.
    else
      merged << [start, stop]                # No overlap. Add this range to the answer list as a new one.
    end
  end                                        # each_with_object hands back the filled-up merged list.
end

# ---------------------------------------------------------------
# 12. Top N words
#
# Examples:
#   top_words("the cat and the hat and the bat", 2) => [["the", 3], ["and", 2]]
#   top_words("b a", 2)                               => [["a", 1], ["b", 1]]
#
# Big idea: Pull out the words, count them, sort by "most used", and take the top few.
# ---------------------------------------------------------------
def top_words(text, n)
  text.downcase                              # Make everything small so "The" and "the" match.
      .scan(/\w+/)                           # Find every word: ["the", "cat", "and", ...]
      .tally                                 # Count each word: {"the"=>3, "cat"=>1, ...}
      .sort_by { |word, count| [-count, word] } # Sort biggest count first (the minus flips the order).
      # If counts tie, sort those words A to Z.
      .first(n) # Keep just the top n.
end

# ---------------------------------------------------------------
# 13. Deep sum (recursion)
#
# Examples:
#   deep_sum([1, [2, [3, [4]], 5]]) => 15
#   deep_sum([])                    => 0
#
# Big idea: Boxes inside boxes. If you find a number, count it.
# If you find another box, open it and do the same thing inside.
# ---------------------------------------------------------------
def deep_sum(arr)
  arr.sum { |x| x.is_a?(Array) ? deep_sum(x) : x }
  # For each thing x in the list:
  #   Is x another list (a box)?  -> Call deep_sum on it to add up what's inside.
  #   Otherwise x is a number     -> Just use the number.
  # sum adds all those results together.
end

# ---------------------------------------------------------------
# 14. Rotate a square grid 90° clockwise
#
# Examples:
#   rotate([[1, 2], [3, 4]])                  => [[3, 1], [4, 2]]
#   rotate([[1, 2, 3], [4, 5, 6], [7, 8, 9]]) => [[7, 4, 1], [8, 5, 2], [9, 6, 3]]
#
# Big idea: Flip the grid along its diagonal, then flip each row left-to-right.
# Those two flips together turn it a quarter turn.
# ---------------------------------------------------------------
def rotate(matrix)
  matrix.transpose                           # Rows become columns: [[1,2],[3,4]] -> [[1,3],[2,4]]
        .map(&:reverse)                      # Flip each row backwards:         -> [[3,1],[4,2]]
end

# ---------------------------------------------------------------
# 15. FizzBuzz
#
# Examples:
#   fizzbuzz(5)       => ["1", "2", "Fizz", "4", "Buzz"]
#   fizzbuzz(15).last => "FizzBuzz"
# ---------------------------------------------------------------
def fizzbuzz(n)
  (1..n).map do |i|                          # Count from 1 up to n, and build a new list from the answers.
    if (i % 15).zero? then "FizzBuzz"        # Splits evenly by 15 (so by both 3 and 5)? Say "FizzBuzz".
    elsif (i % 3).zero? then "Fizz"          # Splits evenly by 3? Say "Fizz".
    elsif (i % 5).zero? then "Buzz"          # Splits evenly by 5? Say "Buzz".
    else i.to_s                              # Otherwise, just say the number (as text).
    end                                      # Whatever we "said" goes into the new list.
  end
end

# ---------------------------------------------------------------
# 16. Longest substring with no repeated letters (sliding window)
#
# Examples:
#   longest_unique_substring("abcabcbb") => 3   ("abc")
#   longest_unique_substring("bbbbb")    => 1   ("b")
#   longest_unique_substring("pwwkew")   => 3   ("wke")
#
# Big idea: Imagine a stretchy window over the word. The right side keeps moving
# forward. If a letter repeats inside the window, scoot the left side past the old copy.
# ---------------------------------------------------------------
def longest_unique_substring(s)
  last_seen = {}                             # A notebook: "letter -> the last spot I saw it".
  start = best = 0                           # start = left edge of the window. best = longest window so far.
  s.each_char.with_index do |c, i|           # Move the right edge forward one letter (c) at a time. i is its spot.
    if last_seen.key?(c) && last_seen[c] >= start # Have we seen this letter, and is the old copy inside our window?
      start = last_seen[c] + 1               # Then scoot the left edge to just after the old copy.
    end
    last_seen[c] = i                         # Write down where we saw this letter now.
    best = [best, i - start + 1].max         # How wide is the window? If it's a new record, remember it.
  end
  best                                       # Give back the record.
end

# ---------------------------------------------------------------
# 17. Product of everything except me (no dividing)
#
# Examples:
#   product_except_self([1, 2, 3, 4]) => [24, 12, 8, 6]
#
# Big idea: For each spot, the answer = (everything multiplied to my left)
#                                     x (everything multiplied to my right).
# Do one walk left-to-right, then one walk right-to-left.
# ---------------------------------------------------------------
def product_except_self(nums)
  n = nums.size                              # How many numbers there are.
  result = Array.new(n, 1)                   # Make an answer list full of 1s: [1, 1, 1, 1]
  left = 1                                   # "Everything to my left multiplied together." Nothing yet, so 1.
  (0...n).each do |i|                        # Walk from the first spot to the last.
    result[i] = left                         # Save the left side's total in this spot.
    left *= nums[i]                          # Multiply this number in, ready for the next spot.
  end
  right = 1                                  # "Everything to my right multiplied together." Nothing yet, so 1.
  (n - 1).downto(0) do |i|                   # Walk backwards, from the last spot to the first.
    result[i] *= right                       # Multiply the right side's total into this spot.
    right *= nums[i]                         # Multiply this number in, ready for the next spot (to the left).
  end
  result                                     # Each spot now holds left total x right total.
end

# ---------------------------------------------------------------
# 18. Binary search
#
# Examples:
#   binary_search([1, 3, 5, 7, 9, 11], 7) => 3
#   binary_search([1, 3, 5], 4)           => nil
#
# Big idea: Like guessing a number from 1 to 100. Guess the middle.
# "Too low"? Throw away the bottom half. "Too high"? Throw away the top half.
# ---------------------------------------------------------------
def binary_search(sorted, target)
  lo = 0
  hi = sorted.size - 1 # lo = first spot we might look at, hi = last spot.
  while lo <= hi                             # Keep going while there's still somewhere to look.
    mid = (lo + hi) / 2                      # Pick the middle spot (whole numbers only, so it rounds down).
    case sorted[mid] <=> target              # Compare the middle number to the target. <=> says -1, 0, or 1.
    when 0 then return mid                   # 0 means they're equal. Found it! Give back the spot.
    when -1 then lo = mid + 1                # -1 means middle is too small. Look only to the right.
    else hi = mid - 1                        # Otherwise middle is too big. Look only to the left.
    end
  end
  nil                                        # Nowhere left to look. It's not there.
  # Ruby's built-in shortcut:
  #   i = sorted.bsearch_index { |x| x >= target }  # first spot where the number is >= target
  #   i if i && sorted[i] == target                 # only count it if it's actually the target
end

# ---------------------------------------------------------------
# 19. Total spend per customer
#
# Examples:
#   orders = [{ customer: "amy", amount: 20 },
#             { customer: "bo",  amount: 5 },
#             { customer: "amy", amount: 7 }]
#   spend_by_customer(orders) => { "amy" => 27, "bo" => 5 }
#
# Big idea: Put each customer's orders in their own pile, add up each pile,
# then sort from biggest spender to smallest.
# ---------------------------------------------------------------
def spend_by_customer(orders)
  orders.group_by { |o| o[:customer] } # Make a pile for each customer: {"amy"=>[order, order], "bo"=>[order]}
        .transform_values { |os| os.sum { |o| o[:amount] } } # Swap each pile for the total of its amounts: {"amy"=>27, "bo"=>5}
        .sort_by { |_cust, total| -total }   # Sort biggest total first (the minus flips the order).
        .to_h                                # Sorting gave us a list of pairs. Turn it back into a hash.
  # Another way:
  #   totals = Hash.new(0)                   # A hash where every new name starts at 0.
  #   orders.each { |o| totals[o[:customer]] += o[:amount] } # Add each order to that customer's total.
  #   totals.sort_by { |_, t| -t }.to_h      # Sort biggest first and turn back into a hash.
end

# ---------------------------------------------------------------
# 20. LRU cache ("Least Recently Used")
#
# Examples:
#   cache = LRUCache.new(2)
#   cache.put(:a, 1)
#   cache.put(:b, 2)
#   cache.get(:a)    => 1    (:a is now most recently used)
#   cache.put(:c, 3)          (over capacity: evicts :b, the least recently used)
#   cache.get(:b)    => nil
#   cache.get(:c)    => 3
#
# Big idea: A small shelf that only holds a few things. When it's full and you add
# something new, the thing you haven't touched in the longest time gets kicked off.
# A Ruby hash remembers the order things went in, so the oldest is always at the front.
# ---------------------------------------------------------------
class LRUCache
  attr_reader :capacity                      # Lets outside code ask "how big is the shelf?"

  def initialize(capacity)                   # This runs when someone writes LRUCache.new(2).
    @capacity = capacity                     # Remember how many things the shelf can hold.
    @store = {}                              # The shelf itself. Front = touched longest ago. Back = touched most recently.
  end

  def get(key)
    return nil unless @store.key?(key)       # Not on the shelf? Give back nothing.

    value = @store.delete(key)               # Take it off the shelf (and hold on to its value).
    @store[key] = value                      # Put it back at the end, so it's now the "most recent".
    # This line also gives back the value.
  end

  def put(key, value)
    @store.delete(key)                       # If it's already on the shelf, take it off first.
    @store[key] = value                      # Put it at the end as the "most recent" thing.
    @store.shift if @store.size > capacity   # Too many things? Kick off the one at the front (the oldest).
  end
end
