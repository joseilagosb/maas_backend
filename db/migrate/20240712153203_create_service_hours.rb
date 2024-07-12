class CreateServiceHours < ActiveRecord::Migration[7.1]
  def change
    create_table :service_hours do |t|
      t.integer :hour
      t.references :service_day, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
