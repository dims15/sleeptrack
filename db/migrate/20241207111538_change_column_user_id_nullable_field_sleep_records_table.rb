class ChangeColumnUserIdNullableFieldSleepRecordsTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :sleep_records, :user_id, false
  end
end
