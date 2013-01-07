require 'test/unit'
require_relative '../../lib/bankapi/account_storage'
  
class TestAccountStorage < Test::Unit::TestCase
	def test_has_account
		instance = AccountStorage.new
		assert_equal(false, instance.has_account("not_exist"))
	end

	def test_add_account
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 10.to_money)

		assert_equal(true, instance.has_account(account_name))
		assert_equal(10, instance.get_account(account_name))
	end

	def test_delete_account
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 10.to_money)

		assert_equal(true, instance.has_account(account_name))
		assert_equal(10, instance.get_account(account_name))
		
		instance.delete_account(account_name)
		assert_equal(nil, instance.get_account(account_name))
	end

	def test_get_account
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 20.to_money)

		assert_equal(true, instance.has_account(account_name))
		assert_equal(20, instance.get_account(account_name))
		
		assert_equal(false, instance.has_account("not_exist"))
		assert_equal(nil, instance.get_account("not_exist"))
	end

	def test_set_account
		account_name = "account"
		instance = AccountStorage.new
		instance.set_account(account_name, 20.to_money)

		assert_equal(true, instance.has_account(account_name))
		assert_equal(20, instance.get_account(account_name))
	end

	def test_add_money
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 10.to_money)
		instance.add_money(account_name, 20)

		assert_equal(30, instance.get_account(account_name))
	end

	def test_remove_money
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 30.to_money)
		instance.remove_money(account_name, 20)

		assert_equal(10, instance.get_account(account_name))
	end

	def test_get_transactions
		account_name = "account"
		instance = AccountStorage.new
		instance.add_account(account_name, 10.to_money)
		instance.add_money(account_name, 20)
		instance.remove_money(account_name, 25)

		assert_equal(5, instance.get_account(account_name))
		assert_equal([[10, "CZK"], [20, "CZK"], [-25, "CZK"]], instance.get_transactions(account_name))
	end
end