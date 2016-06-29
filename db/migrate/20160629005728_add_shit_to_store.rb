class AddShitToStore < ActiveRecord::Migration
  def change
    add_column :stores, :currency, :string
    add_column :stores, :shop_earliest, :string
    add_column :stores, :name, :string
  end
end
