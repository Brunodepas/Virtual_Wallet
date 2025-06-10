class CreateAccountsDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts_discounts do |t|
      t.references :account, foreign_key: true
      t.references :discount, foreign_key: true
      t.timestamps
    end
  end
end
