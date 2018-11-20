class Region < ApplicationRecord
  has_many :countries
  validates :name, :presence => true

  # def self.search(search)
  #   if search
  #     region = Region.find_by(name: query)
  #     if region
  #       self.where(id: region)
  #     end
  #   end
  # end
end
