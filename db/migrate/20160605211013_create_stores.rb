class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :user_id
      t.string :code
      t.string :token
      t.string :shop_url

      t.timestamps null: false
    end
  end
end
