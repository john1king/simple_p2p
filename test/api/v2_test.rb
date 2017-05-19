require 'test_helper'

class API::V2Test < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    API::Root
  end

  def json_response
    JSON.parse(last_response.body)
  end

  test 'should create user' do
    post '/api/v2/users', { name: 'a', amount: 100}
    assert last_response.created?
    assert_kind_of Integer, json_response['id']
  end

  test 'should create borrow tradings and refund tradings' do
    post '/api/v2/users', { name: 'a', amount: 0}
    borrower = json_response['id']
    post '/api/v2/users', { name: 'b', amount: 100}
    lender = json_response['id']
    post "/api/v2/users/#{borrower}/borrowings", { from: lender, money: 70 }
    assert_equal 200, last_response.status
    assert_equal({}, json_response)

    get "/api/v2/users/#{borrower}/balance"
    assert_equal '70.0', json_response['amount']

    post "/api/v2/users/#{borrower}/repayments", { to: lender, money: 50 }

    get "/api/v2/users/#{borrower}/balance"
    assert_equal '20.0', json_response['amount']
  end

  test 'should get balances of users' do
    user_a = User.create!({ name: 'a', amount: 100})
    user_b = User.create!({ name: 'b', amount: 100})
    user_c = User.create!({ name: 'c', amount: 100})

    user_a.borrow_from(user_b, 100)
    user_b.borrow_from(user_c, 70)
    user_c.borrow_from(user_a, 30)

    get "/api/v2/users/#{user_a.id}/balance"
    assert_equal({
      'amount' => '170.0',
      'amount_borrowed' => '100.0',
      'amount_lend' => '30.0',
    }, json_response)

    get "/api/v2/users/#{user_b.id}/balance"
    assert_equal({
      'amount' => '70.0',
      'amount_borrowed' => '70.0',
      'amount_lend' => '100.0',
    }, json_response)

    get "/api/v2/users/#{user_c.id}/balance"
    assert_equal({
      'amount' => '60.0',
      'amount_borrowed' => '30.0',
      'amount_lend' => '70.0',
    }, json_response)

    get "/api/v2/users/#{user_a.id}/borrowings", { from: user_b.id }
    assert_equal({
      'borrowed_money' => '100.0',
    }, json_response)

    get "/api/v2/users/#{user_c.id}/borrowings", { from: user_b.id }
    assert_equal({
      'borrowed_money' => '-70.0',
    }, json_response)
  end

  test 'create error message' do
    post '/api/v2/users', { name: '', amount: nil }
    assert_equal 400, last_response.status
    assert_equal "{\"error\":\"Name can't be blank\"}", last_response.body

    get '/api/v2/users/10000/balance'
    assert_equal 404, last_response.status
    assert_equal "{\"error\":\"Couldn't find User with 'id'=10000\"}", last_response.body

    a = User.create!({ name: 'a', amount: 100})
    b = User.create!({ name: 'b', amount: 100})
    a.borrow_from(b, 50)

    post "/api/v2/users/#{b.id}/borrowings", { from: a.id, money: 50 }
    assert_equal 400, last_response.status
    assert_equal "{\"error\":\"can not borrow money from the user\"}", last_response.body

    post "/api/v2/users/#{a.id}/repayments", { to: b.id, money: 70 }
    assert_equal 400, last_response.status
    assert_equal "{\"error\":\"to much money refund\"}", last_response.body

    post "/api/v2/users/#{a.id}/borrowings", { from: b.id, money: 70 }
    assert_equal 400, last_response.status
    assert_equal "{\"error\":\"Amount must be greater than or equal to 0\"}", last_response.body
  end

end
