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

  mount API::V1
end
