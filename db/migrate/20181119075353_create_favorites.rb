class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.references :accommodation, foreign_key: true
      t.references :flight, foreign_key: true
      t.integer :budget

      t.timestamps
    end
  end
end
