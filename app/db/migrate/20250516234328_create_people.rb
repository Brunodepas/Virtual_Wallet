class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :dni
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :phone
      t.string :email
      t.timestamps
    end
  end
end