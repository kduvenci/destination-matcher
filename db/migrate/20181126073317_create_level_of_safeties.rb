class CreateLevelOfSafeties < ActiveRecord::Migration[5.2]
  def change
    create_table :level_of_safeties do |t|
      t.float :safety_rank
      t.string :overrall_risk
      t.string :pickpoket_risk
      t.string :mugging_risk
      t.string :scams_risk
      t.string :transport_and_taxis_risk
      t.string :natural_disasters_risk
      t.string :terrorism_risk
      t.string :women_travelers_risk
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
