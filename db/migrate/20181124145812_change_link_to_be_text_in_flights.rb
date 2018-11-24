class ChangeLinkToBeTextInFlights < ActiveRecord::Migration[5.2]
  def change
    change_column :flights, :booking_url, :text
  end
end
