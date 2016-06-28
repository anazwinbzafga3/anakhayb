class ChangeToalPriceInOrders < ActiveRecord::Migration
  def change
  	change_column :orders, :total_price, :decimal
  	change_column :customers, :total_spent, :decimal
  	change_column :orders, :creation_date, :string
  	change_column :customers, :creation_date, :string
  end
end
