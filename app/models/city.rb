class City < ApplicationRecord
  mount_uploader :photo, PhotoUploader
  belongs_to :country
  has_many :accommodations
  has_many :flights
  validates :name, :photo, :meal_average_price_cents, :airport_key, :presence => true
end
