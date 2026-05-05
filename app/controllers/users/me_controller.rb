class Users::MeController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email
      }
    }, status: :ok
  end

  def update
      if current_user.update(user_params)
        render json: { user: user_payload(current_user) }, status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
