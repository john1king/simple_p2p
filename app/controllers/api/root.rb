
require_dependency "decimal_money"

class API::Root < Grape::API
  format :json
  prefix :api

  rescue_from ActiveRecord::RecordNotFound do |e|
    error!({ error: e.message }, 404)
  end

  rescue_from Loan::TransferError do |e|
    error!({ error: e.message }, 400)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    error!({ error: e.record.errors.full_messages.join(',') }, 400)
  end

  rescue_from ActiveRecord::RangeError do |e|
    error!({ error: 'Oops, you are so rich' }, 400)
  end

  mount API::V1
  mount API::V2

  add_swagger_documentation
end
