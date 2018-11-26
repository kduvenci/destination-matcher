class City < ApplicationRecord
  mount_uploader :photo, PhotoUploader
  belongs_to :country
  has_many :accommodations
  has_many :flights
  has_one :level_of_safety
  validates :name, :photo, :meal_average_price_cents, :airport_key, :presence => true
end
