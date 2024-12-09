module ErrorHandlingHelper
  extend ActiveSupport::Concern

  def add_rescue_error(errors, message)
    ValidationErrorHelper.add_error(errors, :base, message)

    raise ValidationError.new(errors)
  end
end
