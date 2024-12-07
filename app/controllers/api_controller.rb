class ApiController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing


  private

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
