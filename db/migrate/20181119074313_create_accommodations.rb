class CreateAccommodations < ActiveRecord::Migration[5.2]
  def change
    create_table :accommodations do |t|
      t.references :city, foreign_key: true
      t.string :name
      t.integer :price
      t.integer :star
      t.string :photo

      t.timestamps
    end
  end
end
