class City < ApplicationRecord
  belongs_to :country
  has_many :accommodations
  has_many :flights
  validates :name, :photo, :meal_average_price_cents, :airport_key, :presence => true
end
