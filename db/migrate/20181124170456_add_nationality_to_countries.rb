class AddNationalityToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :nationality, :string
  end
end
