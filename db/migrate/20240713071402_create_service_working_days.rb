class CreateServiceWorkingDays < ActiveRecord::Migration[7.1]
  def change
    create_table :service_working_days do |t|
      t.references :service, null: false, foreign_key: true
      t.integer :day
      t.integer :from
      t.integer :to

      t.timestamps
    end
  end
end
