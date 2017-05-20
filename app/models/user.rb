class User < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :amount , numericality: { greater_than_or_equal_to: 0 }

  has_many :borrowings, class_name: 'Loan', foreign_key: 'borrower_id'
  has_many :loans, class_name: 'Loan', foreign_key: 'lender_id'

  # 从其他用户处借钱
  def borrow_from(lender, money)
    raise Loan::TransferError, 'can not borrow money from the user' if lender.money_borrowed_from(self) > 0
    Loan.transfer(lender, self, money) do
      BorrowTrading.record!(self, lender, money)
    end
  end

  # 还款给其他用户
  def refund_to(lender, money)
    raise Loan::TransferError, 'to much money refund' if money_borrowed_from(lender) < money
    Loan.transfer(lender, self, -money) do
      RefundTrading.record!(self, lender, money)
    end
  end

  # 借钱给其他用户（主要为了方便调用）
  def lend_to(borrower, money)
    borrower.borrow_from(self, money)
  end

  # 从其他用户处借入的金额，< 0 表示借出
  def money_borrowed_from(lender)
    Loan.get_lend_money(lender, self)
  end

  # 借入总金额
  def amount_borrowed
    borrowings.where('money > 0').sum(:money) - loans.where('money < 0').sum(:money)
  end

  # 借出的总金额
  def amount_lend
    loans.where('money > 0').sum(:money) - borrowings.where('money < 0').sum(:money)
  end

end
