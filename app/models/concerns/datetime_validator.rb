module DatetimeValidator
  extend ActiveSupport::Concern

  included do
    validate :validate_datetime_format_for_field
    validate :validate_datetime_field_order
  end

  private

  def validate_datetime_format_for_field
    datetime_fields.each do |field|
      value = send(field)

      next if value.blank?

      begin
        DateTime.parse(value.to_s)
      rescue ArgumentError
        errors.add(field, "must be a valid datetime")
      end
    end
  end

  def validate_datetime_field_order
    datetime_field_pairs.each do |start_field, end_field|
      start_value = send(start_field)
      end_value = send(end_field)

      next if start_value.blank? || end_value.blank?

      if DateTime.parse(start_value.to_s) >= DateTime.parse(end_value.to_s)
        errors.add(end_field, "#{end_field.to_s.humanize} must be greater than #{start_field.to_s.humanize}")
      end
    end
  end

  def datetime_fields
    []
  end

  def datetime_field_pairs
    []
  end
end
