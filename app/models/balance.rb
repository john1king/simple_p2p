
# 用户 user_id 借给用户 other_user_id 的钱, money > 0 表示借出, money < 0 表示借入
class Balance < ApplicationRecord

  validate :user_id_order

  def self.between(user, other_user)
    user_id, other_user_id = [user.id, other_user.id].sort
    find_or_create_by!(user_id: user_id, other_user_id: other_user_id)
  end

  # 借出时 +money, 借入时 -money
  def self.update_between(user, other_user, money)
    balance = between(user, other_user)
    money = -money unless balance.user_id == user.id
    balance.money += money
    balance.save!
  end

  private

  def user_id_order
    if user_id == other_user_id
      errors.add(:base, 'can not trade with oneself')
    elsif user_id > other_user_id
      errors.add(:base, 'user id order error')
    end
  end

end
