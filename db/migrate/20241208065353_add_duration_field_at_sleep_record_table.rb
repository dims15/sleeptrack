class AddDurationFieldAtSleepRecordTable < ActiveRecord::Migration[8.0]
  def change
    add_column :sleep_records, :duration, :int
  end
end
