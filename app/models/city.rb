class City < ApplicationRecord
  belongs_to :country
  validates :name, :photo, :meal_average_price_cents
end
