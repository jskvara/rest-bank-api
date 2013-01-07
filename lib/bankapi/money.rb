
class Money
	attr_accessor :amount, :currency

	def initialize(amount = 0, currency = "CZK")
		@amount = amount
		@currency = currency.to_s.upcase
	end

	def ==(other)
		other = check_class(other)
		@amount == other.amount and @currency == other.currency
	end

	def +(other)
		other = check_class(other)
		if @currency != other.currency
			raise "Currency is different"
		end

		Money.new(@amount + other.amount, @currency)
	end

	def -(other)
		other = check_class(other)
		if @currency != other.currency
			raise "Currency is different"
		end

		Money.new(@amount - other.amount, @currency)
	end

	def check_class(other)
		if (other.is_a?(Money))
			return other
		end

		if !other.respond_to?(:to_money)
			raise TypeError, "Class '#{other.class}' do not have to_money method."
		end

		other.to_money
	end

	# dynamic method to_<currency>
	def method_missing(name, *args)
		if !name.match(/^to_/) 
			super
		end

		currencies = get_currencies
		currency = name[-3, 3].upcase
		if !currencies.has_key?(currency)
			super
		end

		if !currencies.has_key?(@currency)
			raise NoMethodError, "Undefined currency rate: '#{@currency}'"
		end
		
		Money.new(@amount * currencies[@currency] / currencies[currency], currency)
	end

	def to_s
		"#{@amount} #{@currency}"
	end

	def to_i
		@amount
	end

	protected
	def get_currencies
		{"CZK" => 1, "GBP" => 31.056, "USD" => 19.162}
	end
end

class Fixnum
	def to_money
		Money.new(self)
	end
end

class String
	def to_money
		self_arr = self.split
		amount = self_arr.first.to_i
		currency = self_arr.last.upcase

		Money.new(amount, currency)
	end
end