class Khraw < ActiveRecord::Migration
  def change
  	add_column :customers, :customer_id, :string
  end
end
