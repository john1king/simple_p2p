class API::V1 < Grape::API
  version 'v1', using: :path

  helpers do
    params :pair do
      requires :borrower_id, type: Integer, desc: 'Borrower id'
      requires :lender_id, type: Integer, desc: 'Lender id'
    end

    params :trading do
      use :pair
      requires :money, type: BigDecimal, desc: 'Transaction amount'
    end

    def borrower
      User.find(params[:borrower_id])
    end

    def lender
      User.find(params[:lender_id])
    end
  end

  resource :users do
    desc 'create user'
    params do
      requires :name, type: String, desc: 'User name'
      optional :amount, type: BigDecimal, desc: 'User amount'
    end
    post do
      User.create!(name: params[:name], amount: params[:amount].presence || 0)
    end

    desc 'get user balance'
    get ':id/balance' do
      user = User.find(params[:id])
      {
        amount: user.amount,
        amount_borrowed: user.amount_borrowed,
        amount_lend: user.amount_lend,
      }
    end

  end

  resource :borrowings do
    desc 'create a borrow trading'
    params do
      use :trading
    end
    post do
      status 200
      borrower.borrow_from(lender, params[:money])
      {}
    end

    desc 'get borrowings between two users'
    params do
      use :pair
    end
    get do
      { borrowed_money: borrower.money_borrowed_from(lender) }
    end
  end

  resource :repayments do
    desc 'create a refund trading'
    params do
      use :trading
    end
    post do
      status 200
      borrower.refund_to(lender, params[:money])
      {}
    end
  end
end
