class API::V2 < Grape::API
  version 'v2', using: :path

  helpers do
    def current_user
      @current_user ||= User.find(params[:id])
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

    route_param :id do
      desc 'get user balance'
      get 'balance' do
        {
          amount: current_user.amount,
          amount_borrowed: current_user.amount_borrowed,
          amount_lend: current_user.amount_lend,
        }
      end

       resource :borrowings do
        desc 'create a borrow trading'
        params do
          requires :from, type: Integer, desc: 'Borrower id'
          requires :money, type: BigDecimal, desc: 'Transaction amount'
        end
        post do
          status 200
          current_user.borrow_from(User.find(params[:from]), params[:money])
          {}
        end

        desc 'get borrowings between two users'
        params do
          requires :from, type: Integer, desc: 'Borrower id'
        end
        get do
          { borrowed_money: current_user.money_borrowed_from(User.find(params[:from])) }
        end
      end

      resource :repayments do
        desc 'create a refund trading'
        params do
          requires :to, type: Integer, desc: 'Lender id'
          requires :money, type: BigDecimal, desc: 'Transaction amount'
        end
        post do
          status 200
          current_user.refund_to(User.find(params[:to]), params[:money])
          {}
        end
      end

    end
  end
end
