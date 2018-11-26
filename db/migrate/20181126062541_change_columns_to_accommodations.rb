class ChangeColumnsToAccommodations < ActiveRecord::Migration[5.2]
  def change
    change_column :accommodations, :image_url, :text
    change_column :accommodations, :booking_url, :text
  end
end
