class RemoveFavoriteFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_reference :users, :favorite, foreign_key: true
  end
end
