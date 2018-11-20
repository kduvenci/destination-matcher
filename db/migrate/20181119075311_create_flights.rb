class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.time :depart_depature_time
      t.time :depart_arrival_time
      t.time :return_departure_time
      t.time :return_arrival_time
      t.string :departure_location
      t.string :return_location
      t.integer :price
      t.string :airline_name

      t.timestamps
    end
  end
end
