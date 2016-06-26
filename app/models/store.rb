class Store < ActiveRecord::Base

	belongs_to :user
	has_many :orders
	has_many :customers
	validates_presence_of :shop_url
	validates_presence_of :code
	validates_presence_of :token
end
