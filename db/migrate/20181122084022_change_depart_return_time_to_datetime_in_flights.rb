class ChangeDepartReturnTimeToDatetimeInFlights < ActiveRecord::Migration[5.2]
  def change
    remove_column :flights, :depart_arrival_time
    add_column :flights, :depart_arrival_time, :datetime

    remove_column :flights, :depart_departure_time
    add_column :flights, :depart_departure_time, :datetime
    
    remove_column :flights, :return_arrival_time
    add_column :flights, :return_arrival_time, :datetime
    
    remove_column :flights, :return_departure_time
    add_column :flights, :return_departure_time, :datetime
  end
end
