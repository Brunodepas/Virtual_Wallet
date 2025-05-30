class ChangeDateColumnInMovements < ActiveRecord::Migration[8.0]
  def change
    change_column :movements, :date, :datetime
  end
end
