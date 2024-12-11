class ApiController < ActionController::Base
  include Pagy::Backend

  allow_browser versions: :modern

  skip_before_action :verify_authenticity_token
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ValidationError, with: :handle_validation_error
  rescue_from NotFoundError, with: :handle_not_found_error

  private

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_validation_error(e)
    render json: { message: "Validation failed", errors: e.errors }, status: :unprocessable_entity
  end

  def handle_not_found_error(e)
    render json: { message: "Record not found" }, status: :not_found
  end

  def pagination_metadata(pagy)
    {
      current_page: pagy.page,
      next_page: pagy.next,
      prev_page: pagy.prev,
      total_pages: pagy.pages,
      total_count: pagy.count
    }
  end
end
