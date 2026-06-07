class Api::V1::PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    prompts = Prompt.includes(:user, :tags)

    render json: prompts,
           each_serializer: PromptSerializer,
           current_user: current_user
  end

  def mine
    prompts = current_user.prompts.includes(:user, :tags)

    render json: prompts,
           each_serializer: PromptSerializer,
           current_user: current_user
  end

  def show
    prompt = Prompt.includes(:user, :tags).find(params[:id])

    render json: prompt,
           serializer: PromptSerializer,
           current_user: current_user
  end

  def create
    attributes = prompt_params

    prompt = current_user.prompts.build(
      attributes.except(:tag_names)
    )

    if prompt.save
      sync_prompt_tags(prompt, attributes[:tag_names]) if attributes.key?(:tag_names)

      render json: prompt,
             serializer: PromptSerializer,
             current_user: current_user,
             status: :created
    else
      render json: { errors: prompt.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    attributes = prompt_params

    prompt = current_user.prompts.find(params[:id])

    if prompt.update(attributes.except(:tag_names))
      sync_prompt_tags(prompt, attributes[:tag_names]) if attributes.key?(:tag_names)

      render json: prompt,
             serializer: PromptSerializer,
             current_user: current_user,
             status: :ok
    else
      render json: { errors: prompt.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    prompt = current_user.prompts.find(params[:id])

    prompt.destroy

    render json: { message: "Prompt deleted successfully" },
           status: :ok
  end

  private

  def prompt_params
    params.require(:prompt).permit(
      :title,
      :description,
      :content,
      :prompt_type,
      images: [],
      tag_names: []
    )
  end

  def sync_prompt_tags(prompt, tag_names)
    prompt.tags = normalized_tag_names(tag_names).map do |name|
      Tag.find_or_create_by!(name: name)
    end
  end

  def normalized_tag_names(tag_names)
    Array(tag_names)
      .map { |name| name.to_s.strip.downcase }
      .reject(&:blank?)
      .uniq
  end
end
