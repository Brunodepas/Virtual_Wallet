class CreateMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :movements do |t|
      t.float :amount
      t.date :date
      t.string :type
      t.string :status
      t.string :reason
      t.references :origin, foreign_key:{to_table: :accounts}
      t.references :destination, foreign_key:{to_table: :accounts}
      t.references :history, foreign_key:{to_table: :accounts}
      t.references :user, foreign_key:true
      t.timestamps
    end
  end
end
