# Ruby Interview Drills
# ---------------------------------------------------------------
# Fill in each method, then run:   ruby ruby_tests.rb
# Run one drill:                   ruby ruby_tests.rb -n /two_sum/
# Check against the answer key:    SOLUTIONS=1 ruby ruby_tests.rb
#
# Each drill lists the methods it's designed to make you practice.
# Try to solve it without looking them up first, then check the hint.
# ---------------------------------------------------------------

# 1. Return the indices of the two numbers that add up to target.
#    two_sum([2, 7, 11, 15], 9) => [0, 1]
#    Practice: Hash, each_with_index, key?
def two_sum(nums, target)
  seen = {}
  nums.each_with_index do |n, i|
    complement = target - n
    return [seen[complement], i] if seen.key?(complement)

    seen[n] = i
  end
  nil
end

# 2. Are two strings anagrams? Ignore case.
#    anagram?("Listen", "Silent") => true
#    Practice: downcase, chars, sort  OR  tally
def anagram?(a, b)
  raise NotImplementedError
end

# 3. Group words that are anagrams of each other (order of groups doesn't matter).
#    group_anagrams(%w[eat tea tan ate nat bat]) => [["eat","tea","ate"], ["tan","nat"], ["bat"]]
#    Practice: group_by, values
def group_anagrams(words)
  raise NotImplementedError
end

# 4. Index of the first character that appears only once, or -1.
#    first_unique_char("leetcode") => 0
#    Practice: tally, each_char.with_index  OR  index
def first_unique_char(s)
  raise NotImplementedError
end

# 5. Valid brackets? "()[]{}" => true, "(]" => false, "([)]" => false
#    Practice: Array as a stack (push / pop / empty?), Hash lookup
def valid_brackets?(s)
  raise NotImplementedError
end

# 6. The k most frequent numbers (highest count first).
#    top_k_frequent([1,1,1,2,2,3], 2) => [1, 2]
#    Practice: tally, max_by(k) or sort_by, map(&:first)
def top_k_frequent(nums, k)
  raise NotImplementedError
end

# 7. Palindrome, ignoring case and non-alphanumeric chars.
#    palindrome?("A man, a plan, a canal: Panama") => true
#    Practice: downcase, gsub / delete with regex, reverse
def palindrome?(s)
  raise NotImplementedError
end

# 8. Run-length encode a string.
#    compress("aaabccdddd") => "a3b1c2d4"
#    Practice: chars.chunk_while (or slice_when), map, join, string interpolation
def compress(s)
  raise NotImplementedError
end

# 9. Max sum of any contiguous subarray (Kadane's algorithm).
#    max_subarray([-2,1,-3,4,-1,2,1,-5,4]) => 6
#    Practice: each / reduce, [a, b].max
def max_subarray(nums)
  raise NotImplementedError
end

# 10. Moving average of window size k, as floats rounded to 2 places.
#     moving_average([1, 2, 3, 4, 5], 3) => [2.0, 3.0, 4.0]
#     Practice: each_cons, sum, fdiv, round
def moving_average(nums, k)
  raise NotImplementedError
end

# 11. Merge overlapping intervals.
#     merge_intervals([[1,3],[8,10],[2,6],[15,18]]) => [[1,6],[8,10],[15,18]]
#     Practice: sort_by, each_with_object, last, destructuring |(start, stop)|
def merge_intervals(intervals)
  raise NotImplementedError
end

# 12. Top n words by frequency (case-insensitive). Break ties alphabetically.
#     top_words("the cat and the hat and the bat", 2) => [["the", 3], ["and", 2]]
#     Practice: scan(/\w+/), tally, sort_by { [-count, word] }, first(n)
def top_words(text, n)
  raise NotImplementedError
end

# 13. Sum every number in an arbitrarily nested array, without using flatten.
#     deep_sum([1, [2, [3, [4]], 5]]) => 15
#     Practice: recursion, is_a?(Array), sum with a block
def deep_sum(arr)
  raise NotImplementedError
end

# 14. Rotate a square matrix 90 degrees clockwise.
#     rotate([[1,2],[3,4]]) => [[3,1],[4,2]]
#     Practice: transpose, map(&:reverse)
def rotate(matrix)
  raise NotImplementedError
end

# 15. Classic FizzBuzz from 1..n, returning an array of strings.
#     fizzbuzz(5) => ["1","2","Fizz","4","Buzz"]
#     Practice: (1..n).map, case/when or modulo, to_s
def fizzbuzz(n)
  raise NotImplementedError
end

# 16. Length of the longest substring with no repeated characters.
#     longest_unique_substring("abcabcbb") => 3   ("abc")
#     Practice: sliding window, Hash of last-seen index, each_char.with_index
def longest_unique_substring(s)
  raise NotImplementedError
end

# 17. Product of every element except self, without division. O(n).
#     product_except_self([1,2,3,4]) => [24,12,8,6]
#     Practice: Array.new(n, 1), (n-1).downto(0), index math
def product_except_self(nums)
  raise NotImplementedError
end

# 18. Find target's index in a sorted array, or nil. Write it by hand first,
#     then try bsearch_index.
#     binary_search([1,3,5,7,9,11], 7) => 3
#     Practice: while loop, integer division, bsearch_index
def binary_search(sorted, target)
  raise NotImplementedError
end

# 19. Business-style: given orders, return total spend per customer,
#     highest first, as a Hash.
#     orders = [{customer: "amy", amount: 20}, {customer: "bo", amount: 5}, {customer: "amy", amount: 7}]
#     spend_by_customer(orders) => {"amy" => 27, "bo" => 5}
#     Practice: group_by, transform_values, sum, sort_by, to_h
#     (Alt: Hash.new(0) + each)
def spend_by_customer(orders)
  raise NotImplementedError
end

# 20. OOP: build a tiny LRU cache with a fixed capacity.
#     get(key) returns the value or nil and marks key as recently used.
#     put(key, val) inserts/updates; evicts the least recently used key when full.
#     Practice: class, initialize, attr_reader, Ruby Hash insertion order,
#               delete, first, shift
class LRUCache
  def initialize(capacity)
    raise NotImplementedError
  end

  def get(key)
    raise NotImplementedError
  end

  def put(key, value)
    raise NotImplementedError
  end
end
