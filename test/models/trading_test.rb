require 'test_helper'

class TradingTest < ActiveSupport::TestCase
  test "should create trading when borrow and refund" do
    a = User.create!(amount: 100)
    b = User.create!(amount: 100)

    a.borrow_from(b, 30)
    assert_equal 1, Trading.count
    assert_equal 30, BorrowTrading.last_record.money
    assert_equal a.id, BorrowTrading.last_record.user_id

    a.refund_to(b, 20)
    assert_equal 2, Trading.count
    assert_equal 20, RefundTrading.last_record.money
    assert_equal a.id, RefundTrading.last_record.user_id
  end

  test 'amount_borrowed and amount_lend' do
    a = User.create!(name: 'a', amount: 100)
    b = User.create!(name: 'b', amount: 100)
    c = User.create!(name: 'c', amount: 100)

    a.borrow_from(b, 80)
    a.refund_to(b, 30)
    a.lend_to(c, 150)
    c.refund_to(a, 50)

    assert_equal 50, Trading.amount_borrowed_of(a)
    assert_equal 100, Trading.amount_lend_of(a)
    assert_equal 50, Trading.amount_borrowed_between(a, b)
    assert_equal(-50, Trading.amount_lend_between(a, b))

    assert_equal 0, Trading.amount_borrowed_of(b)
    assert_equal 50, Trading.amount_lend_of(b)

    assert_equal 100, Trading.amount_borrowed_of(c)
    assert_equal 0, Trading.amount_lend_of(c)
  end
end
