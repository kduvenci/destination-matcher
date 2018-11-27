class Accommodation < ApplicationRecord
  belongs_to :city
  has_many :favorites

  NON_VAL_ATTRS = ["id", "created_at", "updated_at"]
  VAL_ATTRS = Accommodation.attribute_names.reject{ |attr| NON_VAL_ATTRS.include?(attr) }
  validates_presence_of VAL_ATTRS
  validates :price, numericality: { other_than: 0 }
  # def self.search(search)
  #   if search
  #     accomodation = Accommodation.find_by
  # end
end
