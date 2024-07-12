class AddColumnsToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :name, :string
    add_column :services, :active, :boolean, default: true
  end
end
