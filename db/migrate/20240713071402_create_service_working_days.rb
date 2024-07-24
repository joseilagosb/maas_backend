class CreateServiceWorkingDays < ActiveRecord::Migration[7.1]
  def change
    create_table :service_working_days do |t|
      t.references :service, null: false, foreign_key: true
      t.integer :day
      t.integer :from
      t.integer :to
      
      t.timestamps

      t.index [:day, :service_id], name: "index_service_working_days_day_on_service_id"
    end
  end
end
