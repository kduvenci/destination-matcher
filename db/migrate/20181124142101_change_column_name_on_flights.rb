class ChangeColumnNameOnFlights < ActiveRecord::Migration[5.2]
  def change
    rename_column :flights, :airline_name, :depart_airline_name
  end
end
