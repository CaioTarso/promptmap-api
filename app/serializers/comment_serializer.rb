class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :content,
             :parent_id,
             :comment_likes_count,
             :created_at,
             :updated_at,
             :liked_by_current_user

  belongs_to :user

  has_many :replies

  def liked_by_current_user
    current_user = instance_options[:current_user]

    return false unless current_user

    object.comment_likes.exists?(user_id: current_user.id)
  end
end
