class AddCancelledToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cancelled, :string
  end
end
