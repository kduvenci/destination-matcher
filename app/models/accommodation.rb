class Accommodation < ApplicationRecord
  belongs_to :city
  has_many :favorites
  validates :name, :price, :star, :photo, :presence => true
end
