class Prompt < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  has_many :favorited_by, through: :favorites, source: :user

  has_many :prompt_tags, dependent: :destroy
  has_many :tags, through: :prompt_tags

  has_many_attached :images

  enum :prompt_type, { document: 0, image: 1, code: 2, video: 3 }
end
