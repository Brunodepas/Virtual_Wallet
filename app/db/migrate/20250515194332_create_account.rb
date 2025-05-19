class CreateAccount < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key:true
      t.string :alias, null: false
      t.string :cvu, null: false
      t.integer :balance  #Estaría expresado en centavos en la tabla
      t.integer :amount_point
      t.string :coin
      t.string :status
      t.string :level
      t.timestamps
    end
  end
end 
