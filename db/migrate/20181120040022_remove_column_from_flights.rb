class RemoveColumnFromFlights < ActiveRecord::Migration[5.2]
  def change
    remove_column :flights, :depart_depature_time, :time
  end
end
