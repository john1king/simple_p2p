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
    post '/api/v1/users', { name: 'a', money: 100}
    assert last_response.created?
    assert_kind_of Integer, json_response['id']
  end

  test 'should create borrow tradings and refund tradings' do
    post '/api/v1/users', { name: 'a', money: 0}
    from = json_response['id']
    post '/api/v1/users', { name: 'b', money: 100}
    to = json_response['id']
    post '/api/v1/borrow_tradings', { from: from, to: to, money: 70 }
    assert_equal 201, last_response.status

    get "/api/v1/users/#{from}/balances"
    assert_equal '70.0', json_response['moeny']

    post '/api/v1/refund_tradings', { from: from, to: to, money: 50 }

    get "/api/v1/users/#{from}/balances"
    assert_equal '20.0', json_response['moeny']
  end


  test 'should get balances of users' do
    post '/api/v1/users', { name: 'a', money: 100}
    a = json_response['id']

    post '/api/v1/users', { name: 'b', money: 100}
    b = json_response['id']

    post '/api/v1/users', { name: 'c', money: 100}
    c = json_response['id']

    post '/api/v1/borrow_tradings', { from: a, to: b, money: 100 }
    post '/api/v1/borrow_tradings', { from: b, to: c, money: 70 }
    post '/api/v1/borrow_tradings', { from: c, to: a, money: 30 }

    get "/api/v1/users/#{a}/balances"

    assert_equal '170.0', json_response['moeny']
    assert_equal '100.0', json_response['borrow_money']
    assert_equal '30.0', json_response['lend_money']

    get "/api/v1/users/#{b}/balances"
    assert_equal '70.0', json_response['moeny']
    assert_equal '70.0', json_response['borrow_money']
    assert_equal '100.0', json_response['lend_money']

    get "/api/v1/users/#{c}/balances"
    assert_equal '60.0', json_response['moeny']
    assert_equal '30.0', json_response['borrow_money']
    assert_equal '70.0', json_response['lend_money']

    get "/api/v1/users/balances", { from: a, to: b }
    assert_equal '100.0', json_response['money']

    get "/api/v1/users/balances", { from: c, to: b }
    assert_equal '-70.0', json_response['money']
  end

end
