class CreateSaving < ActiveRecord::Migration[8.0]
  def change
    create_table :savings do |t|
      t.string :description, null: false
      t.integer :goal_amount, null: false
      t.integer :current_amount, default: 0, null: false
      t.references :account, foreign_key: true 
      t.timestamps

    end
  end
end
