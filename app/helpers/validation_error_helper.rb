module ValidationErrorHelper
  def self.add_error(errors, field, message)
    errors[field] ||= []
    errors[field] << message
  end
end
