class Country < ApplicationRecord
  has_many :cities
  validates :name, presence: true
  validates :language, presence: true
  validates :english_level, presence: true
  validates :currency, presence: true
  validates :region, presence: true
end
