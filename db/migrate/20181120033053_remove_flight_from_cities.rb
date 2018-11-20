class RemoveFlightFromCities < ActiveRecord::Migration[5.2]
  def change
    remove_reference :cities, :flight, foreign_key: true
  end
end
