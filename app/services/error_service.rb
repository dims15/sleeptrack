class ErrorService < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super(format_errors(errors))
  end

  private

  def format_errors(errors)
    errors.map { |field, messages| "#{field}: #{messages.join(', ')}" }.join('; ')
  end
end
