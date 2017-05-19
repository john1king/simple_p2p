class API::P2P < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api

  resource :users do
    desc 'create user'
    params do
      requires :name, type: String, desc: 'User name'
      optional :amount, type: BigDecimal, desc: 'User amount'
    end
    post do
      User.create!(name: params[:name], amount: params[:amount].presence || 0)
    end

    desc 'get user balances'
    get ':id/balances' do
      user = User.find(params[:id])
      {
        amount: user.amount,
        amount_borrowed: user.amount_borrowed,
        amount_lend: user.amount_lend,
      }
    end

    desc 'get balances between two users'
    params do
      requires :borrower_id, type: Integer, desc: 'Borrower id'
      requires :lender_id, type: Integer, desc: 'Lender id'
    end
    get 'balances' do
      {
        money: User.find(params[:borrower_id]).money_borrowed_from(User.find(params[:lender_id]))
      }
    end

  end

  resource :loans do
    desc 'create a borrow trading'
    params do
      requires :borrower_id, type: Integer, desc: 'Borrower id'
      requires :lender_id, type: Integer, desc: 'Lender id'
      requires :money, type: BigDecimal, desc: 'Number of borrowed money'
    end
    post do
      User.find(params[:borrower_id]).borrow_from(User.find(params[:lender_id]), params[:money])
      {}
    end
  end

  resource :repayments do
    desc 'create a refund trading'
    params do
      requires :borrower_id, type: Integer, desc: 'Borrower id'
      requires :lender_id, type: Integer, desc: 'Lender id'
      requires :money, type: BigDecimal, desc: 'Number of borrowed money'
    end
    post do
      User.find(params[:borrower_id]).refund_to(User.find(params[:lender_id]), params[:money])
      {}
    end
  end

end
