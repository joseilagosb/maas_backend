class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|

      t.timestamps
    end
  end
end
