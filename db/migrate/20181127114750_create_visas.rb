class CreateVisas < ActiveRecord::Migration[5.2]
  def change
    create_table :visas do |t|
      t.text :relationship
      t.references :country, foreign_key: true

      t.timestamps
    end
  end
end
