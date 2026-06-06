class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :content,
             :user_id,
             :prompt_id,
             :parent_id,
             :comment_likes_count,
             :created_at,
             :updated_at,
             :liked_by_current_user

  has_one :user, serializer: UserSerializer
  has_one :prompt
  has_many :replies, serializer: CommentSerializer

  def liked_by_current_user
    current_user = instance_options[:current_user]
    return false if current_user.blank?
    object.liked_by.include?(current_user)
  end
end
