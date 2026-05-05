class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      user: user_payload(resource),
      token: request.env["warden-jwt_auth.token"],
      message: "Logged in successfully."
    }, status: :ok
  end

  def respond_to_on_destroy(*)
    render json: {
      message: "Logged out successfully."
    }, status: :ok
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
