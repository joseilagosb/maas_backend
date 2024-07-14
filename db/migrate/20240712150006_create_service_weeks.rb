class CreateServiceWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :service_weeks do |t|
      t.integer :week
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
