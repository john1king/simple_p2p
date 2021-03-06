
# 记录贷款人（lender_id）借给借款人（borrower_id ）的金额
# 两个用户之间的金钱关系只保存一条记录，user_id 较小的一方最为 lender
# money > 0 表示借出, money < 0 表示借入
class Loan < ApplicationRecord
  class TransferError < StandardError; end

  belongs_to :lender, class_name: 'User'
  belongs_to :borrower, class_name: 'User'

  validate :user_id_order

  class << self
    # 从 user 转账到 other_user
    # 参数 money > 0 为借出，< 0 为借入
    def transfer(user, other_user, money)
      transaction do
        user.lock!
        loan = between(user, other_user)
        user.amount -= money
        other_user.amount += money
        money = -money unless loan.lender_id == user.id
        loan.money += money
        user.save!
        other_user.save!
        loan.save!
        yield if block_given?
      end
    end

    # 获取 lender 借出给 borrower 的金额
    def get_lend_money(lender, borrower)
      loan = between(lender, borrower)
      loan.lender_id == lender.id ? loan.money : -loan.money
    end

    private

    def between(user, other_user)
      lender_id, borrower_id = [user.id, other_user.id].sort
      find_or_create_by!(lender_id: lender_id, borrower_id: borrower_id)
    end
  end

  private

  def user_id_order
    if lender_id == borrower_id
      errors.add(:base, 'can not trade with oneself')
    elsif lender_id > borrower_id
      errors.add(:base, 'user id order error')
    end
  end

end
