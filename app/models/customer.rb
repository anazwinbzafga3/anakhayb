class Customer < ActiveRecord::Base
	belongs_to :store
	validates_uniqueness_of :customer_id, scope: :store_id
end
