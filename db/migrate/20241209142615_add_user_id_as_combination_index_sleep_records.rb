class AddUserIdAsCombinationIndexSleepRecords < ActiveRecord::Migration[8.0]
  def change
    remove_index :sleep_records, [ :sleep_time, :wake_time ]
    add_index :sleep_records, [ :sleep_time, :wake_time, :user_id ], unique: true, name: 'index_user_unique_sleep_and_wake_times'
  end
end
