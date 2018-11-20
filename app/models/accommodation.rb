class Accommodation < ApplicationRecord
  belongs_to :city
  has_many :favorites
  validates :name, :price, :star, :photo, :presence => true

  # def self.search(search)
  #   if search
  #     accomodation = Accommodation.find_by
  # end
end
