class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :prompt, counter_cache: true
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :comment_likes, dependent: :destroy
  has_many :liked_by, through: :comment_likes, source: :user
  validate :parent_must_be_root_comment
  validate :parent_belongs_to_same_prompt


  def parent_must_be_root_comment
    return if parent.nil?

    if parent.parent_id.present?
      errors.add(:parent_id, "cannot reply to a reply")
    end
  end


  def parent_belongs_to_same_prompt
    return if parent.nil?

    if parent.prompt_id != prompt_id
      errors.add(:parent_id, "must belong to the same prompt")
    end
  end
end
