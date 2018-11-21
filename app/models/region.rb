class Region < ApplicationRecord
  has_many :countries

  AREAS = ["Europe", "Eastern Europe", "North America", "South America", "Central America", "Southeast Asia", "East Asia", "Middle East", "South Africa", "North Africa"]

  validates :name, :presence => true, inclusion: { in: AREAS }
end
