class City < ApplicationRecord
  belongs_to :country
  has_many :accommodations
  validates :name, :photo, :meal_average_price_cents
end
