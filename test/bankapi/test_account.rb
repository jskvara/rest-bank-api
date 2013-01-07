require 'test/unit'
require_relative '../../lib/bankapi/account'
require_relative '../../lib/bankapi/account_storage'
  
class TestAccount < Test::Unit::TestCase
	def setup
		@storage = AccountStorage.new()
	end

	def test_create
		account_name = "ac1"

		instance = Account.new(@storage)
		instance.create(account_name, 1000)

		assert_equal(1000, instance.deposit(account_name).to_i)

		# cannot convert to money
		assert_raise BankApiError do
			instance.create(account_name, true)
		end
	end

	def test_delete
		account_name = "ac4"

		instance = Account.new(@storage)
		instance.create(account_name, 1000)

		assert_equal(1000, instance.deposit(account_name).to_i)

		instance.delete(account_name)
		assert_raise BankApiError do
			instance.deposit(account_name)
		end
	end

	def test_transfer
		instance = Account.new(@storage)
		account1 = "a1"
		account2 = "a2"
		instance.create(account1, 1000)
		instance.create(account2, 2000)

		instance.transfer(account1, account2, 1000)

		assert_equal(0, instance.deposit(account1).to_i)
		assert_equal(3000, instance.deposit(account2).to_i)

		# not existing account
		assert_raise BankApiError do
			instance.transfer("not_existing_account", account2, 1000)
		end

		# not enough money
		assert_raise BankApiError do
			instance.transfer(account1, account2, 10000000)
		end
	end

	def test_transfer_different_currencies
		instance = Account.new(@storage)
		account1 = "a1"
		account2 = "a2"
		instance.create(account1, 1000)
		instance.create(account2, Money.new(2000, "USD"))

		instance.transfer(account1, account2, 1000)

		assert_equal(0, instance.deposit(account1))
		deposit = instance.deposit(account2)
		assert_equal("USD", deposit.currency)
		assert(1000 < deposit.to_i)
	end

	def test_transaction
		instance = Account.new(@storage)
		account1 = "a1"
		account2 = "a2"
		instance.create(account1, 1000)
		instance.create(account2, 2000)

		instance.transfer(account1, account2, 1000)
		instance.transfer(account2, account1, 2000)

		assert_equal([[1000, "CZK"], [-1000, "CZK"], [2000, "CZK"]], instance.transactions(account1))
		assert_equal([[2000, "CZK"], [1000, "CZK"], [-2000, "CZK"]], instance.transactions(account2))
	end

	def test_convert_money
		instance = Account.new(@storage)
		account1 = "a1"
		instance.create(account1, 1000)

		converted = instance.convert_money(account1, "GBP")
		assert_equal("GBP", converted.currency)

		# cannot convert money
		assert_raise BankApiError do
			instance.convert_money(account1, "ABC")
		end
	end
end