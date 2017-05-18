require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should borrow from other user" do
    a = User.create!(name: 'a', money: 100)
    b = User.create!(name: 'b')
    b.borrow_from(a, 30)
    assert_equal 30, b.money
    assert_equal 70, a.money
  end

  test "should not borrow from other user when money > other user money" do
    a = User.create!(name: 'a', money: 100)
    b = User.create!(name: 'b')
    assert_raises(ActiveRecord::RecordInvalid) do
      b.borrow_from(a, 200)
    end
  end

  test "should update balance when borrow" do
    a = User.create!(name: 'a', money: 100)
    b = User.create!(name: 'b')
    b.borrow_from(a, 30)
    # 这个返回值比较蛋疼，分别不出是借入还是借出
    assert_equal 30, Balance.between(a, b).money
    assert_equal 30, Balance.between(b, a).money
  end

  test "should refund to other user" do
    a = User.create!(name: 'a', money: 30)
    b = User.create!(name: 'b', money: 70)
    Balance.between(a, b).update(money: -30)
    a.refund_to(b, 30)
    assert_equal 100, b.money
    assert_equal 0, a.money
  end

  test "should not refund to other user when remaining money < 0" do
    a = User.create!(name: 'a', money: 20)
    b = User.create!(name: 'b', money: 70)
    Balance.between(a, b).update(money: -30)
    assert_raises(ActiveRecord::RecordInvalid) do
      a.refund_to(b, 30)
    end
  end

  test "should not refund to other user when refund money > borrow money" do
    a = User.create!(name: 'a', money: 30)
    b = User.create!(name: 'b', money: 80)
    Balance.between(a, b).update(money: -10)
    assert_raises(RuntimeError) do
      a.refund_to(b, 20)
    end
  end

end
