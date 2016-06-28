class AddCreationDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :creation_date, :date
    add_column :customers, :creation_date, :date
  end
end
