class CreateAccountsPromos < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts_promos do |t|
      t.references :account, foreign_key: true
      t.references :promo, foreign_key: true
      t.timestamps
    end
  end
end
