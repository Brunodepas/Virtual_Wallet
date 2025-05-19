class CreateUser < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string  :username
      t.string  :password
      t.boolean :admin_check
      t.references :person, foreign_key: true
      t.timestamps
    end
  end
end

