class Flight < ApplicationRecord
  belongs_to :city
  has_many :favorites
  validates :depart_depature_time, :depart_arrival_time, :return_departure_time, :return_arrival_time, :departure_location, :return_location, :price, :airline_name, :presence => true
end
