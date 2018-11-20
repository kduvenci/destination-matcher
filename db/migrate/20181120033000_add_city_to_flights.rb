class AddCityToFlights < ActiveRecord::Migration[5.2]
  def change
    add_reference :flights, :city, foreign_key: true
  end
end
