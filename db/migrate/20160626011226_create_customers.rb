class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :orders_count
      t.integer :created_at
      t.integer :total_spent
      t.integer :store_id

      t.timestamps null: false
    end
  end
end
