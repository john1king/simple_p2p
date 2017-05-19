require 'test_helper'

class API::P2PTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    API::P2P
  end

  def json_response
    JSON.parse(last_response.body)
  end

  test 'should create user' do
    post '/api/v1/users', { name: 'a', amount: 100}
    assert last_response.created?
    assert_kind_of Integer, json_response['id']
  end

  test 'should create borrow tradings and refund tradings' do
    post '/api/v1/users', { name: 'a', amount: 0}
    borrower = json_response['id']
    post '/api/v1/users', { name: 'b', amount: 100}
    lender = json_response['id']
    post '/api/v1/loans', { borrower_id: borrower, lender_id: lender, money: 70 }
    assert_equal 201, last_response.status

    get "/api/v1/users/#{borrower}/balances"
    assert_equal '70.0', json_response['amount']

    post '/api/v1/repayments', { borrower_id: borrower, lender_id: lender, money: 50 }

    get "/api/v1/users/#{borrower}/balances"
    assert_equal '20.0', json_response['amount']
  end

  test 'should get balances of users' do
    post '/api/v1/users', { name: 'a', amount: 100}
    a = json_response['id']

    post '/api/v1/users', { name: 'b', amount: 100}
    b = json_response['id']

    post '/api/v1/users', { name: 'c', amount: 100}
    c = json_response['id']

    post '/api/v1/loans', { borrower_id: a, lender_id: b, money: 100 }
    post '/api/v1/loans', { borrower_id: b, lender_id: c, money: 70 }
    post '/api/v1/loans', { borrower_id: c, lender_id: a, money: 30 }


    get "/api/v1/users/#{a}/balances"
    assert_equal({
      'amount' => '170.0',
      'amount_borrowed' => '100.0',
      'amount_lend' => '30.0',
    }, json_response)

    get "/api/v1/users/#{b}/balances"
    assert_equal({
      'amount' => '70.0',
      'amount_borrowed' => '70.0',
      'amount_lend' => '100.0',
    }, json_response)

    get "/api/v1/users/#{c}/balances"
    assert_equal({
      'amount' => '60.0',
      'amount_borrowed' => '30.0',
      'amount_lend' => '70.0',
    }, json_response)

    get "/api/v1/users/balances", { borrower_id: a, lender_id: b }
    assert_equal({
      'money' => '100.0',
    }, json_response)

    get "/api/v1/users/balances", { borrower_id: c, lender_id: b }
    assert_equal({
      'money' => '-70.0',
    }, json_response)
  end

end
