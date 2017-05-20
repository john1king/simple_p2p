
class DecimalMoney < Grape::Validations::Base
  def validate_param!(attr_name, params)
    zero = @option.is_a?(Hash) ? @option.fetch(:zero, false) : false
    value = params[attr_name]
    if (value < 0) || (value == 0 && !zero) || value.exponent > 13 || value.truncate(2) != value
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "invalid decimal range"
    end
  end
end
