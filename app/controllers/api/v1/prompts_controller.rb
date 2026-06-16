class Api::V1::PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    prompts = Prompt.includes(:user, :tags)

    prompts = filter_by_search(prompts)
    prompts = filter_by_tags(prompts)
    prompts = filter_by_prompt_types(prompts)
    prompts = filter_by_sort(prompts)

    per_page = [ params.fetch(:per_page, 20).to_i, 100 ].min

    @pagy, prompts = pagy(prompts, limit: per_page)

    render json: {
      data: ActiveModelSerializers::SerializableResource.new(
        prompts,
        each_serializer: PromptSerializer,
        current_user: current_user
      ),
      pagination: {
        page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      }
    }
  end

  def mine
    prompts = current_user.prompts.includes(:user, :tags)

    per_page = [ params.fetch(:per_page, 20).to_i, 100 ].min

    @pagy, prompts = pagy(prompts, limit: per_page)

    render json: {
      data: ActiveModelSerializers::SerializableResource.new(
        prompts,
        each_serializer: PromptSerializer,
        current_user: current_user
      ),
      pagination: {
        page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      }
    }
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


  def filter_by_search(prompts)
    return prompts if params[:search].blank?

    search = "%#{params[:search]}%"

    prompts.where(
      "title LIKE :search OR description LIKE :search OR content LIKE :search",
      search: search
    )
  end

  def filter_by_tags(prompts)
    return prompts if params[:tag].blank?

    prompts.joins(:tags).where(tags: { name: params[:tag] })
  end

  def filter_by_prompt_types(prompts)
    return prompts if params[:prompt_type].blank?

    prompts.where(prompt_type: params[:prompt_type])
  end

  def filter_by_sort(prompts)
    case params[:sort]
    when "popular"
      prompts.order(favorites_count: :desc)
    else
      prompts.order(created_at: :desc)
    end
  end
end
