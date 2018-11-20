class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :language
      t.integer :english_level
      t.string :currency
      t.string :region

      t.timestamps
    end
  end
end
