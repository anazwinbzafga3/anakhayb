class AnalyticsController < ApplicationController

	def index

		@store = current_user.store

		session = ShopifyAPI::Session.new(@store.shop_url, @store.token)

		ShopifyAPI::Base.activate_session(session)

		shop = ShopifyAPI::Shop.current

		@orders = ShopifyAPI::Order.find(:all,:params => {:created_at_min => Date.yesterday, :limit => 250, :status => "any"})

		@total_prices = Array.new

		@orders.each do |order|

			@total_prices.push(order.total_price.to_f)

		end

	end

end
