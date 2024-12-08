module ErrorHandlingHelper
  extend ActiveSupport::Concern

  def add_unique_error(errors, user, exception)
    ValidationErrorHelper.add_error(errors, :base, "A record with this value already exists.")

    raise ErrorService.new(errors)
  end
end
