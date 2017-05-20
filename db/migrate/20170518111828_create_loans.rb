class CreateLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :loans do |t|
      t.integer :lender_id
      t.integer :borrower_id
      t.decimal :money, default: 0, precision: 15, scale: 2
      t.timestamps
    end
    add_index :loans, [:lender_id, :borrower_id], unique: true
    add_index :loans, [:borrower_id]
  end
end
