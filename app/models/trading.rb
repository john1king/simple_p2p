class Trading < ApplicationRecord
  belongs_to :user
  belongs_to :target, class_name: 'User', foreign_key: 'target_user_id'
  validates :money , numericality: { greater_than: 0 }

  class << self
    def record!(user, target, money)
      create!(user: user, target: target, money: money)
    end

    def last_record
      order(id: :desc).first
    end

    def amount_borrowed_of(user)
      amount_of(user: user)
    end

    def amount_lend_of(user)
      amount_of(target: user)
    end

    # 两个用户间结算后的借入金额
    def amount_borrowed_between(user, target)
      amount_between(user, target) - amount_between(target, user)
    end

    def amount_lend_between(user, target)
      amount_borrowed_between(target, user)
    end

    private

    # user 从 target 借入的总金额，计算借出总金额只需交换参数位置即可
    def amount_between(user, target)
      query = { user: user, target: target }
      BorrowTrading.where(query).sum(:money) - RefundTrading.where(query).sum(:money)
    end

    def amount_of(query)
      BorrowTrading.where(query).sum(:money) - RefundTrading.where(query).sum(:money)
    end
  end

end
