class AddVoidedAtToParentalConsents < ActiveRecord::Migration[4.2]
  def change
    add_column :parental_consents, :voided_at, :datetime
    add_index :parental_consents, :voided_at
  end
end
