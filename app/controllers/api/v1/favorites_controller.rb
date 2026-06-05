class Api::V1::FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [ :create, :destroy ]

  def index
    render json: current_user.favorite_prompts
  end

  def create
    @favorite = current_user.favorites.find_or_initialize_by(prompt: @prompt)

    if @favorite.persisted?
      render_favorite("Prompt already favorited", :ok)
    elsif @favorite.save
      render_favorite("Prompt favorited successfully", :created)
    else
      render json: @favorite.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by(prompt: @prompt)

    if @favorite
      @favorite.destroy
      render_favorite("Prompt unfavorited successfully", :ok)
    else
      render json: { error: "Favorite not found" }, status: :not_found
    end
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:prompt_id])
  end

  def render_favorite(message, status)
    @prompt.reload
    render json: {
      message: message,
      prompt_id: @prompt.id,
      favorites_count: @prompt.favorites_count
    }, status: status
  end
end
