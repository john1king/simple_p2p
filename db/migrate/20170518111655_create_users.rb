class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.decimal :amount, default: 0, precision: 10, scale: 2

      t.timestamps
    end
  end
end
