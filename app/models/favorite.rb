class Favorite < ApplicationRecord
  belongs_to :accommodation
  belongs_to :flight
  has_many :users
  validates :budget
end
