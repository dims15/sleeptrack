class CreateUserFollowTable < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.datetime :deleted_at
      t.timestamps
    end

    add_reference :follows, :user, foreign_key: { to_table: :users }
    add_reference :follows, :following_user, foreign_key: { to_table: :users }
    add_index :follows, [:user_id, :following_user_id], unique: true, name: 'index_unique_user_following'
  end
end
