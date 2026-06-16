class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(exception)
    render json: {
      error: "#{exception.model} not found"
    }, status: :not_found
  end

  def parameter_missing(exception)
    render json: {
      error: exception.message
    }, status: :bad_request
  end
end
