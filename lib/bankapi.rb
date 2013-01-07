require 'sinatra'
require 'json'
require_relative 'bankapi/version'
require_relative 'bankapi/account'
require_relative 'bankapi/account_storage'

storage = AccountStorage.new()
account = Account.new(storage)

# homepage
get '/' do
	"<h1>BankAPI version: #{BankApi::VERSION}</h1>" \
	"Available methods:" \
	"<ul>" \
	"	<li>Create account: POST /account/ (JSON Arguments: name [money] [currency])<br />" \
		"<code>curl -H \"Accept: application/json\" -H \"Content-type: application/json\" " \
		"-X POST -d '{\"name\":\":name\", \"money\": 1000, \"currency\": \"USD\"}' http://0.0.0.0:4567/account/ " \
		"</code></li>" \
	"	<li>List accounts: GET <a href='/account/'>/account/</a></li>" \
	"	<li>List account: GET <a href='/account/:name/'>/account/:name/</a></li>" \
	"	<li>Create transfer: POST /account/:name/transaction/ (JSON Arguments: account_to money)<br />" \
		"<code>curl -H \"Accept: application/json\" -H \"Content-type: application/json\" " \
		"-X POST -d '{\"account_to\":\":name2\", \"money\": 1000}' http://0.0.0.0:4567/account/:name/transaction/ " \
		"</code></li>" \
	"	<li>List transactions: GET <a href='/account/:name/transaction/'>/account/:name/transaction/</a></li>" \
	"	<li>Convert currency: POST /account/:name/convert/<br />" \
		"<code>curl -H \"Accept: application/json\" -H \"Content-type: application/json\" " \
		"-X POST -d '{\"currency\": \"USD\"}' http://0.0.0.0:4567/account/:name/convert/</code></li>" \
	"	<li>Delete account: DELETE /account/:name/<br />" \
		"<code>curl -X DELETE http://0.0.0.0:4567/account/:name/</code></li>" \
	"</ul>"
end

# get all accounts
get '/account/' do
	if account.accounts.empty?
		"{\"message\": \"No accounts\"}"
	else
		account.accounts.to_json
	end
end

# create account
post '/account/' do
	begin
		request.body.rewind  # in case someone already read it
		# data = Rack::Utils.parse_nested_query(request.body.read)
		data = JSON.parse request.body.read
	rescue JSON::ParserError
		return "{\"error\": \"Bad JSON arguments: name [money] [currency]\"}"
	end

	begin
		if data['money']
			if data['currency']
				money = Money.new(data['money'], data['currency'])
			else
				money = data['money'].to_money
			end
		else
			money = 0.to_money
		end
		account.create(data['name'], money)
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end
	"{\"success\": true, \"message\": \"Account '#{data['name']}' was created.\"}"
end

# get deposit
get '/account/:name/' do
	name = params[:name]

	begin
		deposit = account.deposit(name)
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end

	"{\"account\": \"#{name}\", \"deposit\": \"#{deposit}\"}"
end

# delete account
delete '/account/:name/' do
	name = params[:name]

	begin
		account.delete(name)
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end

	"{\"message\": \"Account '#{name}' deleted.\"}"
end

# get all transactions
get '/account/:name/transaction/' do
	name = params[:name]

	begin
		transactions = account.transactions(name)
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end

	if transactions.empty?
		return "{\"message\":\"No transactions.\"}"
	end

	transactions.to_json
end

# make transaction
post '/account/:name/transaction/' do
	name = params[:name]

	begin
		request.body.rewind
		data = JSON.parse request.body.read
	rescue JSON::ParserError
		return "{\"error\": \"Bad JSON arguments: account_to money\"}"
	end

	begin
		if data['account_to'] == nil
			raise Exception "Undefined parameter: account_to"
		end

		if data['money'] == nil 
			raise Exception "Undefined parameter: money"
		end
		money = data['money'].to_i

		account.transfer(name, data['account_to'], money)
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end
	"{\"success\": true, \"message\": \"Transfer from account '#{name}' to '#{data['account_to']}' #{money} was successfull.\"}"
end

# convert currency
post '/account/:name/convert/' do
	name = params[:name]

	begin
		request.body.rewind  # in case someone already read it
		data = JSON.parse request.body.read
	rescue JSON::ParserError
		return "{\"error\": \"Bad JSON arguments\"}"
	end

	begin
		account.convert_money(name, data['currency'])
	rescue Exception => e
		return "{\"error\": \"#{e}\"}"
	end
	"{\"success\": true, \"message\": \"Account '#{name}' was converted to currency: #{data['currency']}.\"}"
end

not_found do
	"<h1>Not Found</h1>" \
	"Url '#{request.path_info}' does not exist"
end