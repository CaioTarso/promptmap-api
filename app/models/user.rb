class User < ApplicationRecord
  has_many :prompts
  has_many :comments
  has_many :favorites


  has_many :favorite_prompts, through: :favorites, source: :prompt
end
