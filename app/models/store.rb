class Store < ActiveRecord::Base

	belongs_to :user
	validates_presence_of :shop_url
	validates_presence_of :code
	validates_presence_of :token
end
