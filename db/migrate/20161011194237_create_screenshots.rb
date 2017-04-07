class CreateScreenshots < ActiveRecord::Migration[4.2]
  def change
    create_table :screenshots do |t|
      t.references :team_submission, index: true, foreign_key: true
      t.string :image

      t.timestamps null: false
    end
  end
end
