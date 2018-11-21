class AddColumnToCities < ActiveRecord::Migration[5.2]
  def change
    add_column :cities, :airport_key, :string
  end
end
