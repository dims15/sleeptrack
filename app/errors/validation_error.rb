class ValidationError < FormattedError
  def initialize(errors)
    super(errors)
  end
end
