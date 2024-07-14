class CreateServiceHours < ActiveRecord::Migration[7.1]
  def change
    create_table :service_hours do |t|
      t.integer :hour
      t.references :service_day, null: false, foreign_key: true
      t.references :designated_user, null: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
