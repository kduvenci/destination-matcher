class Country < ApplicationRecord
  has_many :cities
  belongs_to :region
  validates :name, :language, :english_level, :currency, :region, :presence => true
end
