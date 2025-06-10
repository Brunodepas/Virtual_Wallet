class CreatePromos < ActiveRecord::Migration[8.0]
  def change
    create_table :promos do |t|
      t.string :description
      t.integer :cost
      t.date :end_date
      t.references :accounts, foreign_key:true
      t.timestamps
    end
  end
end
