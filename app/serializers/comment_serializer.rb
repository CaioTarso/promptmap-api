class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :content,
             :user_id,
             :prompt_id,
             :parent_id,
             :comment_likes_count,
             :created_at,
             :updated_at,
             :liked_by_current_user,
             :user,
             :prompt

  has_many :replies, serializer: CommentSerializer

  def user
    return unless object.user.present?

    ActiveModelSerializers::SerializableResource.new(
      object.user,
      serializer: UserSerializer,
      current_user: instance_options[:current_user]
    )
  end

  def prompt
    return unless object.prompt.present?

    ActiveModelSerializers::SerializableResource.new(
      object.prompt,
      serializer: PromptSerializer,
      current_user: instance_options[:current_user]
    )
  end

  def liked_by_current_user
    current_user = instance_options[:current_user]
    return false if current_user.blank?

    object.liked_by.include?(current_user)
  end
end
