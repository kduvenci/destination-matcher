class Country < ApplicationRecord
  has_many :cities
  validates :name, :language, :english_level, :currency, :region
end
