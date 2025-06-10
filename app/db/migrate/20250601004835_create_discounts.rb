class CreateDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :discounts do |t|
      t.string :description
      t.integer :cost
      t.integer :percentage
      t.references :accounts, foreign_key:true
      t.timestamps
    end
  end
end
