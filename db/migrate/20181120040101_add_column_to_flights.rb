class AddColumnToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :depart_departure_time, :time
  end
end
