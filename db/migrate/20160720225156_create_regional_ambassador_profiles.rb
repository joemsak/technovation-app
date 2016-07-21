class CreateRegionalAmbassadorProfiles < ActiveRecord::Migration
  def change
    create_table :regional_ambassador_profiles do |t|
      t.string :organization_company_name, null: false
      t.integer :ambassador_since_year, index: true, null: false
      t.belongs_to :account, index: true, null: false
      t.integer :status, null: false, default: 0, index: true

      t.timestamps null: false
    end
  end
end
