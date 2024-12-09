class ApiController < ActionController::Base
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ValidationError, with: :handle_validation_error

  private

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_validation_error(e)
    render json: { errors: e.errors }, status: :unprocessable_entity
  end
end
