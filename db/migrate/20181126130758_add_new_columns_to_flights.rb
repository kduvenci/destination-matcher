class AddNewColumnsToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :depart_code, :string
    add_column :flights, :depart_image_url, :text
    add_column :flights, :return_code, :string
    add_column :flights, :return_image_url, :text
  end
end
