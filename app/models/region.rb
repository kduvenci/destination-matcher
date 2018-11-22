class Region < ApplicationRecord
  has_many :countries
  validates :name, :presence => true
  has_many :cities, through: :countries
end
