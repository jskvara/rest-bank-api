require 'test/unit'
require 'rack/test'
require_relative '../lib/bankapi'

class BankApiTest < Test::Unit::TestCase
	include Rack::Test::Methods

  def app
		Sinatra::Application
  end

  def test_account_get
    get '/account/'
    assert_equal "{\"message\": \"No accounts\"}", last_response.body

    post '/account/', {:name => "account1"}.to_json, "Content-Type" => "application/json"  
    get '/account/'
    assert_equal "{\"account1\":\"0 CZK\"}", last_response.body    
  end

  def test_account_post
    post '/account/'
    assert_equal "{\"error\": \"Bad JSON arguments: name [money] [currency]\"}", last_response.body

    account_name = "account2"
    post '/account/', {:name => account_name}.to_json, "Content-Type" => "application/json"  
    assert_equal "{\"success\": true, \"message\": \"Account '#{account_name}' was created.\"}", last_response.body

    # already exist
    post '/account/', {:name => account_name}.to_json, "Content-Type" => "application/json"  
    assert_equal "{\"error\": \"Account '#{account_name}' already exists\"}", last_response.body

    account_name = "account3"
    post '/account/', {:name => account_name, :money => 1000, :currency => "USD"}.to_json, "Content-Type" => "application/json"  
    assert_equal "{\"success\": true, \"message\": \"Account '#{account_name}' was created.\"}", last_response.body
    get '/account/'
    assert_equal "{\"account1\":\"0 CZK\",\"account2\":\"0 CZK\",\"account3\":\"1000 USD\"}", last_response.body

    account_name = "account4"
    post '/account/', {:name => account_name, :money => 2000}.to_json, "Content-Type" => "application/json"  
    assert_equal "{\"success\": true, \"message\": \"Account '#{account_name}' was created.\"}", last_response.body
    get '/account/'
    assert_equal "{\"account1\":\"0 CZK\",\"account2\":\"0 CZK\",\"account3\":\"1000 USD\",\"account4\":\"2000 CZK\"}", last_response.body
  end

  def test_account_name_get
    get '/account/account/'
    assert_equal "{\"error\": \"Account 'account' does not exist\"}", last_response.body

    account_name = "account7"
    post '/account/', {:name => account_name, :money => 2000}.to_json, "Content-Type" => "application/json"  
    get "/account/#{account_name}/"
    assert_equal "{\"account\": \"#{account_name}\", \"deposit\": \"2000 CZK\"}", last_response.body
    delete "/account/#{account_name}/"
  end

  def test_transaction_get
    get "/account/not_exist/transaction/"
    assert_equal "{\"error\": \"Account 'not_exist' does not exist\"}", last_response.body

    account_name = "account9"
    post '/account/', {:name => account_name, :money => 2000}.to_json, "Content-Type" => "application/json"  
    get "/account/#{account_name}/"
    assert_equal "{\"account\": \"#{account_name}\", \"deposit\": \"2000 CZK\"}", last_response.body

    get "/account/#{account_name}/transaction/"
    assert_equal "[[2000,\"CZK\"]]", last_response.body

    delete "/account/#{account_name}/"
  end

  def test_transaction_post
    account_name = "account10"
    post '/account/', {:name => account_name, :money => 5000, :currency => "USD"}.to_json, "Content-Type" => "application/json"  
    get "/account/#{account_name}/"
    assert_equal "{\"account\": \"#{account_name}\", \"deposit\": \"5000 USD\"}", last_response.body

    account_name2 = "account11"
    post '/account/', {:name => account_name2, :money => 2000}.to_json, "Content-Type" => "application/json"  
    get "/account/#{account_name2}/"
    assert_equal "{\"account\": \"#{account_name2}\", \"deposit\": \"2000 CZK\"}", last_response.body

    post "/account/#{account_name}/transaction/", {:account_to => account_name2, :money => 1000}.to_json
    assert_equal "{\"success\": true, \"message\": \"Transfer from account '#{account_name}' to '#{account_name2}' 1000 was successfull.\"}", last_response.body

    get "/account/#{account_name}/transaction/"
    assert_equal "[[5000,\"USD\"],[-1000,\"USD\"]]", last_response.body

    get "/account/#{account_name2}/transaction/"
    data = JSON.parse last_response.body
    assert_equal(data[0], [2000, "CZK"])
    converted = data[1]
    assert(converted[0] > 2000)
    assert_equal(converted[1], "CZK")

    delete "/account/#{account_name}/"
    delete "/account/#{account_name2}/"
  end

  def test_convert_post
    account_name = "account8"
    post '/account/', {:name => account_name, :money => 2000}.to_json, "Content-Type" => "application/json"  
    get "/account/#{account_name}/"
    assert_equal "{\"account\": \"#{account_name}\", \"deposit\": \"2000 CZK\"}", last_response.body

    post "/account/#{account_name}/convert/", {:currency => "USD"}.to_json, "Content-Type" => "application/json"  
    assert_equal "{\"success\": true, \"message\": \"Account 'account8' was converted to currency: USD.\"}", last_response.body
    get "/account/#{account_name}/"
    
    data = JSON.parse last_response.body
    assert_equal(data['account'], account_name)
    deposit = data['deposit'].to_money
    assert(deposit.to_i < 2000)
    assert_equal(deposit.currency, "USD")

    delete "/account/#{account_name}/"
  end
end