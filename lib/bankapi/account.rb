require_relative 'money'
require_relative 'bankapi_error'

class Account
	def initialize(storage)
		@storage = storage
	end

	def create(name, money)
		check_account_not_exists(name)
		money = check_money(money)
		
		@storage.add_account(name, money)
	end

	def accounts()
		@storage.accounts
	end

	def delete(name)
		check_account_exists(name)

		@storage.delete_account(name)
	end

	def deposit(name)
		check_account_exists(name)

		@storage.get_account(name)
	end

	def transfer(from, to, amount)
		check_account_exists(from)
		check_account_exists(to)

		account_from = @storage.get_account(from)
		account_to = @storage.get_account(to)

		if account_from.to_i < amount
			raise BankApiError, "Not enough money on account '#{from}'"
		end

		@storage.remove_money(from, amount)

		if account_from.currency != account_to.currency
			money = Money.new(amount, account_from.currency)
			amount = money.send("to_#{account_to.currency.downcase}").to_i
		end
		@storage.add_money(to, amount)
	end

	def transactions(name)
		check_account_exists(name)

		@storage.get_transactions(name)
	end

	def convert_money(name, currency)
		check_account_exists(name)

		to_currency_method_name = "to_#{currency.downcase}"
		
		money = @storage.get_account(name)
		begin
			money = money.send(to_currency_method_name)
			@storage.set_account(name, money)
		rescue NoMethodError
			raise BankApiError, "Cannot convert money to #{currency}"
		end

		money
	end

	protected
	def account_exists(name)
		@storage.has_account(name)
	end

	def check_account_exists(name)
		if !account_exists(name)
			raise BankApiError, "Account '#{name}' does not exist"
		end
	end

	def check_account_not_exists(name)
		if account_exists(name)
			raise BankApiError, "Account '#{name}' already exists"
		end
	end

	def check_money(money)

		begin
			if !money.is_a?(Money)
				money = money.to_money
			end
		rescue NoMethodError
			raise BankApiError, "Cannot convert '#{money}' to money"
		end

		money
	end
end