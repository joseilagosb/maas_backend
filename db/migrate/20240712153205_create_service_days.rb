class CreateServiceDays < ActiveRecord::Migration[7.1]
  def change
    create_table :service_days do |t|
      t.integer :day
      t.references :service_week, null: false, foreign_key: true

      t.timestamps
    end
  end
end
