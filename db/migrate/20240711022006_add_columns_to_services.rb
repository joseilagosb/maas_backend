class AddColumnsToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :name, :string
    add_column :services, :from, :date
    add_column :services, :to, :date
  end
end
