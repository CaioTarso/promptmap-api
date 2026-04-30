class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :prompt, counter_cache: true
end
