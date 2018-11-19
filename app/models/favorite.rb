class Favorite < ApplicationRecord
  belongs_to :accommodation
  belongs_to :flight
end
