require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should borrow from other user" do
    a = User.create!(name: 'a', amount: 100)
    b = User.create!(name: 'b', amount: 0)
    b.borrow_from(a, 30)
    assert_equal 70, a.amount
    assert_equal 30, b.amount
  end

  test "should not borrow from user when money > user amount" do
    a = User.create!(name: 'a', amount: 100)
    b = User.create!(name: 'b')
    assert_raises(ActiveRecord::RecordInvalid) do
      b.borrow_from(a, 200)
    end
  end

  test "should update loan after borrowed" do
    a = User.create!(name: 'a', amount: 100)
    b = User.create!(name: 'b')
    b.borrow_from(a, 30)
    # FIXME 分别不出是借入还是借出
    assert_equal 30, Loan.between(a, b).money
    assert_equal 30, Loan.between(b, a).money
  end

  test "should refund to other user" do
    a = User.create!(name: 'a', amount: 30)
    b = User.create!(name: 'b', amount: 70)
    Loan.between(a, b).update(money: -30)
    a.refund_to(b, 30)
    assert_equal 100, b.amount
    assert_equal 0, a.amount
  end

  test "should not refund to other user when amount < 0" do
    a = User.create!(name: 'a', amount: 20)
    b = User.create!(name: 'b', amount: 70)
    Loan.between(a, b).update(money: -30)
    assert_raises(ActiveRecord::RecordInvalid) do
      a.refund_to(b, 30)
    end
  end

  test "should not refund to other user when refund money > borrowed money" do
    a = User.create!(name: 'a', amount: 30)
    b = User.create!(name: 'b', amount: 80)
    Loan.between(a, b).update(money: -10)
    assert_raises(RuntimeError) do
      a.refund_to(b, 20)
    end
  end

  test 'amount_borrowed and amount_lend' do
    a = User.create!(name: 'a', amount: 100)
    b = User.create!(name: 'b', amount: 100)
    c = User.create!(name: 'c', amount: 100)

    a.borrow_from(b, 50)
    a.lend_to(c, 100)

    assert_equal 300, User.sum(:amount)

    assert_equal 50, a.amount
    assert_equal 50, a.amount_borrowed
    assert_equal 100, a.amount_lend

    assert_equal 50, b.amount
    assert_equal 0, b.amount_borrowed
    assert_equal 50, b.amount_lend

    assert_equal 200, c.amount
    assert_equal 100, c.amount_borrowed
    assert_equal 0, c.amount_lend
  end

  test 'money_borrowed_from' do
    a = User.create!(name: 'a', amount: 0)
    b = User.create!(name: 'b', amount: 100)
    a.borrow_from(b, 30)
    assert_equal 30, a.amount
    assert_equal 30, a.money_borrowed_from(b)
    assert_equal -30, b.money_borrowed_from(a)
  end

  test 'should not trade with oneself' do
    a = User.create!(name: 'a', amount: 100)
    assert_raises(ActiveRecord::RecordInvalid){
      a.borrow_from(a, 30)
    }
    assert_raises(ActiveRecord::RecordInvalid){
      a.refund_to(a, 30)
    }
  end

end
