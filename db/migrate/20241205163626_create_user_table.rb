class CreateUserTable < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
