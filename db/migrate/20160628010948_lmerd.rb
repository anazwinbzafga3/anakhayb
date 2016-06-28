class Lmerd < ActiveRecord::Migration
  def change
  	change_column :orders, :total_price, :string
  	change_column :customers, :total_spent, :string
  end
end
