class DropFinancialStatusFromOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :order_id, :integer
  	remove_column :orders, :financial_status
  end
end
