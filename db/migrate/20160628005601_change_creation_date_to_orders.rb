class ChangeCreationDateToOrders < ActiveRecord::Migration
  def change
  	change_column :orders, :creation_date, :string
  	change_column :customers, :creation_date, :string
  end
end
