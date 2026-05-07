class Api::V1::PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    @prompts = Prompt.all
    render json: @prompts
  end

  def show
    @prompt = Prompt.find(params[:id])
    render json: @prompt
  end

  def create
    @prompt = current_user.prompts.build(prompt_params)

    if @prompt.save
      render json: @prompt, status: :created
    else
      render json: @prompt.errors, status: :unprocessable_entity
    end
  end

  def update
    @prompt = current_user.prompts.find(params[:id])

    if @prompt.update(prompt_params)
      render json: @prompt, status: :ok
    else
      render json: @prompt.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt = current_user.prompts.find(params[:id])
    @prompt.destroy
    render json: { message: "Prompt deleted successfully" }, status: :ok
  end

  private

  def prompt_params
    params.require(:prompt).permit(:title, :description, :content, :prompt_type, images: [])
  end
end
