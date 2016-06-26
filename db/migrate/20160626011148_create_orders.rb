class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :created_at
      t.string :status
      t.string :financial_status
      t.integer :total_price
      t.integer :store_id

      t.timestamps null: false
    end
  end
end
