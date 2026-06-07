class PromptSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :content,
             :prompt_type,
             :favorites_count,
             :comments_count,
             :created_at,
             :updated_at,
             :favorited_by_current_user,
             :image_urls

  belongs_to :user, serializer: UserSerializer
  has_many :tags

  def favorited_by_current_user
    current_user = instance_options[:current_user]

    return false unless current_user

    object.favorites.exists?(user_id: current_user.id)
  end

  def image_urls
    return [] unless object.images.attached?

    object.images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_url(
        image,
        only_path: false
      )
    end
  end
end
