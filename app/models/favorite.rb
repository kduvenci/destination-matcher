class Favorite < ApplicationRecord
  belongs_to :accommodation
  belongs_to :flight
  belongs_to :users
  validates :budget, :presence => true
end
