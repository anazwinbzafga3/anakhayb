class AddExportStatusToStores < ActiveRecord::Migration
  def change
  	add_column :stores, :export_status, :string
  end
end
