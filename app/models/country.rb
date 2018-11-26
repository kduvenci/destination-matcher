class Country < ApplicationRecord
  has_many :cities
  belongs_to :region

  NON_VAL_ATTRS = ["id", "created_at", "updated_at"]
  VAL_ATTRS = Country.attribute_names.reject{ |attr| NON_VAL_ATTRS.include?(attr) }
  validates_presence_of VAL_ATTRS
end
