class AddColumnsToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :adults, :string
    add_column :flights, :cabin_class, :string
    add_column :flights, :booking_url, :string
    add_column :flights, :depart_stops, :string
    add_column :flights, :return_stops, :string
    add_column :flights, :agent, :string
    add_column :flights, :return_airline_name, :string
  end
end
