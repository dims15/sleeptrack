class ChangeColumnSleepTimeNullableFieldSleepRecordTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :sleep_records, :sleep_time, false
  end
end
