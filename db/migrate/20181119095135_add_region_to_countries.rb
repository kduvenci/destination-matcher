class AddRegionToCountries < ActiveRecord::Migration[5.2]
  def change
    add_reference :countries, :region, foreign_key: true
  end
end
