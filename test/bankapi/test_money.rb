require 'test/unit'
require_relative '../../lib/bankapi/money'
  
class TestMoney < Test::Unit::TestCase
	def test_equals
		money_usd = Money.new(1000, "USD")
		money_eur = Money.new(1000, "EUR")
		money_usd2 = Money.new(1000, "USD")

		assert_equal(false, money_usd == money_eur)
		assert_equal(true, money_usd != money_eur)
		assert_equal(true, money_usd == money_usd2)
	end

	def test_check_class
		money = Money.new(10)

		assert_raise TypeError do
			money.check_class(Exception)
		end

		money.check_class(Money.new)
	end

	def test_plus
		money_1000 = Money.new(1000, "USD")
		money_500 = Money.new(500, "USD")

		expected = Money.new(1500, "USD")
		assert_equal(expected, money_1000 + money_500)
	end

	def test_minus
		money_1000 = Money.new(1000, "USD")
		money_200 = Money.new(200, "USD")

		expected = Money.new(800, "USD")
		assert_equal(expected, money_1000 - money_200)
	end

	def test_fixnum_to_money
		instance = 150.to_money

		expected = Money.new(150, "CZK")
		assert_equal(instance, expected)
	end

	def test_string_to_money
		instance = "150.0 CZK".to_money

		expected = Money.new(150, "CZK")
		assert_equal(instance, expected)

		instance = instance + 50
		expected = Money.new(200, "CZK")
		assert_equal(instance, expected)
	end

	def test_to_s
		instance = Money.new(150, "CZK")
		assert_equal "150 CZK", instance.to_s
	end

	def test_to_i
		instance = Money.new(150, "CZK")
		assert_equal(150, instance.to_i)
	end

	def test_convert_currency
		assert_raise NoMethodError do
			Money.new(2000, :CZK).to_abc
		end

		assert_raise NoMethodError do
			Money.new(2000, "abc").to_czk
		end

		instance = Money.new(2000, :CZK).to_usd
		assert instance.is_a?(Money)
		assert instance.amount < 2000

		instance = Money.new(2000, :CZK).to_gbp
		assert instance.is_a?(Money)
		assert instance.amount < 2000
	end
end
