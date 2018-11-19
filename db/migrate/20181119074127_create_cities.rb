class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.references :country, foreign_key: true
      t.string :name
      t.string :photo
      t.integer :meal_average_price_cents

      t.timestamps
    end
  end
end
