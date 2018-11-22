class AddColumnToAccommodations < ActiveRecord::Migration[5.2]
  def change
    add_column :accommodations, :address, :string
  end
end
