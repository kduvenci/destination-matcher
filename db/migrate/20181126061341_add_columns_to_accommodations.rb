class AddColumnsToAccommodations < ActiveRecord::Migration[5.2]
  def change
    add_column :accommodations, :image_url, :string
    add_column :accommodations, :booking_url, :string
    add_column :accommodations, :score, :string
    remove_column :accommodations, :star, :integer
    remove_column :accommodations, :photo, :string
  end
end
