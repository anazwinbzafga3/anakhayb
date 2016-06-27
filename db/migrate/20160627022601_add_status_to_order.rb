class AddStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :financial_status, :string
    remove_column :orders, :cancelled, :string
  end
end
