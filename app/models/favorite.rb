class Favorite < ApplicationRecord
  belongs_to :accommodation
  belongs_to :flight
  belongs_to :user
  validates :budget, :presence => true
end
