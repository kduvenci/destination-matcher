class ChangeMealToBeFloatInCities < ActiveRecord::Migration[5.2]
  def change
    change_column :cities, :meal_average_price_cents, :float
  end
end
