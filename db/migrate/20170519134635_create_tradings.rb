class CreateTradings < ActiveRecord::Migration[5.1]
  def change
    create_table :tradings do |t|
      t.integer :user_id, null: false
      t.integer :target_user_id, null: false
      t.string :type, null: false
      t.decimal :money, default: 0, precision: 10, scale: 2
      t.timestamps
    end
    add_index :tradings, :user_id
    add_index :tradings, :target_user_id
  end
end
