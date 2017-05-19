class API::P2P < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api

  resource :users do
    desc 'create user'
    params do
      requires :name, type: String, desc: 'User name'
      optional :money, type: BigDecimal, desc: 'User money'
    end
    post do
      User.create!(name: params[:name], money: params[:money].presence || 0)
    end

    desc 'get user balances'
    get ':id/balances' do
      user = User.find(params[:id])
      {
        id: user.id,
        moeny: user.money,
        borrow_money: user.amount_borrow_money,
        lend_money: user.amount_lend_money,
      }
    end

    desc 'get balances between two users'
    params do
      requires :from, type: Integer, desc: 'User id who borrow money from other'
      requires :to, type: Integer, desc: 'User id who lend moeny to other'
    end
    get 'balances' do
      {
        money: User.find(params[:from]).money_borrow_from(User.find(params[:to]))
      }
    end

  end

  resource :borrow_tradings do
    desc 'create a borrow trading'
    params do
      requires :from, type: Integer, desc: 'User id who borrow money from other'
      requires :to, type: Integer, desc: 'User id who borrow moeny to other'
      requires :money, type: BigDecimal, desc: 'Number of borrow money'
    end
    post do
      User.find(params[:from]).borrow_from(User.find(params[:to]), params[:money])
      {}
    end
  end

  resource :refund_tradings do
    desc 'create a refund trading'
    params do
      requires :from, type: Integer, desc: 'User id who refund money to other'
      requires :to, type: Integer, desc: 'User id who lend moeny to other'
      requires :money, type: BigDecimal, desc: 'Number of borrow money'
    end
    post do
      User.find(params[:from]).refund_to(User.find(params[:to]), params[:money])
      {}
    end
  end

end
