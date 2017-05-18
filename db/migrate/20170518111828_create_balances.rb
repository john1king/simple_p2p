class CreateBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :balances do |t|
      t.integer :user_id
      t.integer :other_user_id
      t.decimal :money, default: 0, precision: 10, scale: 2
      t.timestamps
    end
    add_index :balances, [:user_id, :other_user_id], unique: true
  end
end
