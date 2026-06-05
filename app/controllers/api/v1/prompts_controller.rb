class Api::V1::PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    @prompts = Prompt.includes(:tags).all
    render json: @prompts, include: prompt_includes
  end

  def mine
    @prompts = current_user.prompts.includes(:tags)
    render json: @prompts, include: prompt_includes
  end

  def show
    @prompt = Prompt.find(params[:id])
    render json: @prompt, include: prompt_includes
  end

  def create
    attributes = prompt_params
    @prompt = current_user.prompts.build(attributes.except(:tag_names))

    if @prompt.save
      sync_prompt_tags(@prompt, attributes[:tag_names]) if attributes.key?(:tag_names)
      render json: @prompt, include: prompt_includes, status: :created
    else
      render json: @prompt.errors, status: :unprocessable_entity
    end
  end

  def update
    attributes = prompt_params
    @prompt = current_user.prompts.find(params[:id])

    if @prompt.update(attributes.except(:tag_names))
      sync_prompt_tags(@prompt, attributes[:tag_names]) if attributes.key?(:tag_names)
      render json: @prompt, include: prompt_includes, status: :ok
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
    params.require(:prompt).permit(:title, :description, :content, :prompt_type, images: [], tag_names: [])
  end

  def sync_prompt_tags(prompt, tag_names)
    prompt.tags = normalized_tag_names(tag_names).map do |name|
      Tag.find_or_create_by!(name: name)
    end
  end

  def normalized_tag_names(tag_names)
    Array(tag_names).map { |name| name.to_s.strip.downcase }.reject(&:blank?).uniq
  end

  def prompt_includes
    {
      tags: {
        only: [ :id, :name ]
      }
    }
  end
end
