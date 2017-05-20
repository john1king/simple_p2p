module API
  module Entities
    class User < Grape::Entity
      expose :id, if: { type: :new }

      expose :amount, if: { type: :amount }
      expose :amount_borrowed, if: { type: :amount }
      expose :amount_lend, if: { type: :amount }
    end
  end
end
