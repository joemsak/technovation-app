class CreateStudentProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :student_profiles do |t|
      t.integer :account_id, foreign_key: true, index: true, null: false
      t.string :parent_guardian_email, null: false
      t.string :parent_guardian_name, null: false
      t.string :school_name, null: false

      t.timestamps null: false
    end
  end
end
