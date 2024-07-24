class CreateServiceWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :service_weeks do |t|
      t.integer :week
      t.references :service, null: false, foreign_key: true

      t.timestamps

      t.index [:week, :service_id], name: "index_service_weeks_week_on_service_id"
    end
  end
end
