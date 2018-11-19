class RemoveRegionFromCountries < ActiveRecord::Migration[5.2]
  def change
    remove_column :countries, :region, :string
  end
end
