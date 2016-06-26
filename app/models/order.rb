class Order < ActiveRecord::Base
	belongs_to :store
	validates_uniqueness_of :order_id, scope: :store_id
end
