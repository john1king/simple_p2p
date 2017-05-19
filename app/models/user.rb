class User < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :amount , numericality: { greater_than_or_equal_to: 0 }

  # 从其他用户处借钱
  def borrow_from(lender, money)
    Loan.transfer(lender, self, money)
  end

  # 还款给其他用户
  def refund_to(lender, money)
    raise RuntimeError if money_borrowed_from(lender) < money
    Loan.transfer(lender, self, -money)
  end

  # 借钱给其他用户（主要为了方便调用）
  def lend_to(borrower, money)
    borrower.borrow_from(self, money)
  end

  # 从其他用户处借入的金额，< 0 表示借出
  def money_borrowed_from(lender)
    loan = Loan.between(self, lender)
    if loan.lender_id == self.id
      -loan.money
    else
      loan.money
    end
  end

  # 借入总金额
  def amount_borrowed
    - Loan.where("lender_id = ? and money < 0", [id]).sum(:money) + Loan.where("borrower_id = ? and money > 0", [id]).sum(:money)
  end

  # 借出的总金额
  def amount_lend
    Loan.where("lender_id = ? and money > 0", id).sum(:money) - Loan.where("borrower_id = ? and money < 0", id).sum(:money)
  end

end
