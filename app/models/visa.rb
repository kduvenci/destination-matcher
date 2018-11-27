class Visa < ApplicationRecord
  belongs_to :country
  validates :relationship, presence: true
end
