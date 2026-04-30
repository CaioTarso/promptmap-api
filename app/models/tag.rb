class Tag < ApplicationRecord
  has_many :prompt_tags, dependent: :destroy
  has_many :prompts, through: :prompt_tags

  validates :name, presence: true, uniqueness: true
end
