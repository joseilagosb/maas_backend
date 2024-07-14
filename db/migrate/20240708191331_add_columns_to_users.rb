class AddColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer, default: 0
    add_column :users, :color, :integer
  end
end
