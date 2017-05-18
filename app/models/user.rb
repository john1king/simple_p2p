class User < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :money , numericality: { greater_than_or_equal_to: 0 }

  # 从其他用户处借钱
  def borrow_from(other_user, money)
    update_balance self, other_user, money
  end

  # 还款给其他用户
  def refund_to(other_user, money)
    raise RuntimeError if money_borrow_from(other_user) < money
    update_balance(self, other_user, -money)
  end

  # 从其他用户处借入的金额
  def money_borrow_from(other_user)
    balance = Balance.between(self, other_user)
    if balance.user_id = self.id
      -balance.money
    else
      balance.money
    end
  end

  private

  def update_balance(user, other_user, money)
    self.transaction do
      user.money += money
      other_user.money -= money
      user.save!
      other_user.save!
      Balance.update_between(user, other_user, -money)
    end
  end

end
