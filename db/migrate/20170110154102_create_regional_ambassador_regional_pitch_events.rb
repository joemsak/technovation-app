class CreateRegionalAmbassadorRegionalPitchEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :regional_pitch_events do |t|
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.references :regional_ambassador_profile

      t.timestamps null: false
    end
  end
end
