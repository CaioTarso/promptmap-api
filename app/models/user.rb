class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :prompts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comment_likes, dependent: :destroy

  has_many :favorite_prompts, through: :favorites, source: :prompt
  has_many :liked_comments, through: :comment_likes, source: :comment
end
