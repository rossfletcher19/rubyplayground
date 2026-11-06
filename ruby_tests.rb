require "minitest/autorun"
require_relative(ENV["SOLUTIONS"] ? "ruby_solutions" : "ruby_exercises")

class DrillsTest < Minitest::Test
  def sorted_groups(groups) = groups.map(&:sort).sort

  def test_01_two_sum
    assert_equal [0, 1], two_sum([2, 7, 11, 15], 9)
    assert_equal [1, 2], two_sum([3, 2, 4], 6)
  end

  def test_02_anagram
    assert anagram?("Listen", "Silent")
    refute anagram?("abc", "abd")
  end

  def test_03_group_anagrams
    expected = [%w[eat tea ate], %w[tan nat], %w[bat]]
    assert_equal sorted_groups(expected), sorted_groups(group_anagrams(%w[eat tea tan ate nat bat]))
  end

  def test_04_first_unique_char
    assert_equal 0, first_unique_char("leetcode")
    assert_equal 2, first_unique_char("loveleetcode")
    assert_equal(-1, first_unique_char("aabb"))
  end

  def test_05_valid_brackets
    assert valid_brackets?("()[]{}")
    assert valid_brackets?("{[()]}")
    refute valid_brackets?("(]")
    refute valid_brackets?("([)]")
    refute valid_brackets?("((")
  end

  def test_06_top_k_frequent
    assert_equal [1, 2], top_k_frequent([1, 1, 1, 2, 2, 3], 2)
  end

  def test_07_palindrome
    assert palindrome?("A man, a plan, a canal: Panama")
    refute palindrome?("race a car")
  end

  def test_08_compress
    assert_equal "a3b1c2d4", compress("aaabccdddd")
    assert_equal "", compress("")
  end

  def test_09_max_subarray
    assert_equal 6, max_subarray([-2, 1, -3, 4, -1, 2, 1, -5, 4])
    assert_equal(-1, max_subarray([-3, -1, -2]))
  end

  def test_10_moving_average
    assert_equal [2.0, 3.0, 4.0], moving_average([1, 2, 3, 4, 5], 3)
    assert_equal [1.5, 2.5], moving_average([1, 2, 3], 2)
  end

  def test_11_merge_intervals
    assert_equal [[1, 6], [8, 10], [15, 18]], merge_intervals([[1, 3], [8, 10], [2, 6], [15, 18]])
    assert_equal [[1, 5]], merge_intervals([[1, 4], [4, 5]])
  end

  def test_12_top_words
    assert_equal [["the", 3], ["and", 2]], top_words("the cat and the hat and the bat", 2)
    assert_equal [["a", 1], ["b", 1]], top_words("b a", 2)
  end

  def test_13_deep_sum
    assert_equal 15, deep_sum([1, [2, [3, [4]], 5]])
    assert_equal 0, deep_sum([])
  end

  def test_14_rotate
    assert_equal [[3, 1], [4, 2]], rotate([[1, 2], [3, 4]])
    assert_equal [[7, 4, 1], [8, 5, 2], [9, 6, 3]], rotate([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
  end

  def test_15_fizzbuzz
    assert_equal %w[1 2 Fizz 4 Buzz], fizzbuzz(5)
    assert_equal "FizzBuzz", fizzbuzz(15).last
  end

  def test_16_longest_unique_substring
    assert_equal 3, longest_unique_substring("abcabcbb")
    assert_equal 1, longest_unique_substring("bbbbb")
    assert_equal 3, longest_unique_substring("pwwkew")
    assert_equal 0, longest_unique_substring("")
  end

  def test_17_product_except_self
    assert_equal [24, 12, 8, 6], product_except_self([1, 2, 3, 4])
  end

  def test_18_binary_search
    assert_equal 3, binary_search([1, 3, 5, 7, 9, 11], 7)
    assert_nil binary_search([1, 3, 5], 4)
  end

  def test_19_spend_by_customer
    orders = [{ customer: "amy", amount: 20 }, { customer: "bo", amount: 5 }, { customer: "amy", amount: 7 }]
    result = spend_by_customer(orders)
    assert_equal({ "amy" => 27, "bo" => 5 }, result)
    assert_equal %w[amy bo], result.keys
  end

  def test_20_lru_cache
    cache = LRUCache.new(2)
    cache.put(:a, 1)
    cache.put(:b, 2)
    assert_equal 1, cache.get(:a)   # :a is now most recent
    cache.put(:c, 3)                # evicts :b
    assert_nil cache.get(:b)
    assert_equal 3, cache.get(:c)
    cache.put(:a, 10)
    assert_equal 10, cache.get(:a)
  end
end
