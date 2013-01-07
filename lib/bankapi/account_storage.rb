require_relative 'account'

class AccountStorage
	attr_reader :accounts, :transactions

	def initialize()
		@accounts = {}
		@transactions = {}
	end

	def has_account(name)
		@accounts.has_key?(name)
	end

	def add_account(name, money)
		@accounts[name] = money

		@transactions[name] = []
		@transactions[name] << [money.to_i, money.currency]
	end

	def delete_account(name)
		@accounts.delete(name)
	end

	def get_account(name)
		@accounts[name]
	end

	def set_account(name, money)
		@accounts[name] = money
	end

	def add_money(name, amount)
		money = Money.new(amount, @accounts[name].currency)
		@accounts[name] += money
		@transactions[name] << [money.to_i, money.currency]
	end

	def remove_money(name, amount)
		money = Money.new(amount, @accounts[name].currency)
		@accounts[name] -= money
		@transactions[name] << [-money.to_i, money.currency]
	end

	def get_transactions(name)
		@transactions[name]
	end
end