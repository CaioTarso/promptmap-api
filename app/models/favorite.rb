class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :prompt, counter_cache: true

  validates :user_id, uniqueness: { scope: :prompt_id }
end
