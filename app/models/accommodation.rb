class Accommodation < ApplicationRecord
  mount_uploader :photo, PhotoUploader
  belongs_to :city
  has_many :favorites

  NON_VAL_ATTRS = ["id", "created_at", "updated_at"]
  VAL_ATTRS = Accommodation.attribute_names.reject{ |attr| NON_VAL_ATTRS.include?(attr) }
  validates_presence_of VAL_ATTRS

  # def self.search(search)
  #   if search
  #     accomodation = Accommodation.find_by
  # end
end
