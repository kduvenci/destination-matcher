class Flight < ApplicationRecord
  belongs_to :city
  has_many :favorites

  # NON_VAL_ATTRS = ["id", "created_at", "updated_at"]
  # VAL_ATTRS = Flight.attribute_names.reject{ |attr| NON_VAL_ATTRS.include?(attr) }
  # validates_presence_of VAL_ATTRS
end
