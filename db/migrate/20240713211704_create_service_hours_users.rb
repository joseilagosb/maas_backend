class CreateServiceHoursUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :service_hours_users do |t|
      t.references :service_hour, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
