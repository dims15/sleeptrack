module ModelValidationHelper
  def validate_model(record)
    unless record.valid?
      record.errors.each do |field, message|
        ValidationErrorHelper.add_error(@errors, field.attribute, field.type)
      end
    end
  end
end
