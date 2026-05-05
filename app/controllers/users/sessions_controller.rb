class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      user: user_payload(resource),
      message: "Logged in successfully."
    }, status: :ok
  end

  def respond_to_on_destroy(*)
    head :no_content
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
