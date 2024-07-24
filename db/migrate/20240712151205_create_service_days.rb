class CreateServiceDays < ActiveRecord::Migration[7.1]
  def change
    create_table :service_days do |t|
      t.integer :day
      t.references :service_week, null: false, foreign_key: true

      t.timestamps

      t.index [:day, :service_week_id], name: "index_service_days_day_on_service_week_id"
    end
  end
end
