class CreateSleepRecordsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.datetime :sleep_time
      t.datetime :wake_time

      t.datetime :deleted_at
      t.timestamps
    end

    add_reference :sleep_records, :user, foreign_key: { to_table: :users }
    add_index :sleep_records, [:sleep_time, :wake_time], unique: true, name: 'index_unique_sleep_and_wake_times'
  end
end
