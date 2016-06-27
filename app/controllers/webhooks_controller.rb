class WebhooksController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :get_store
	before_action :verify_webhook

	def order_create
		@store.orders.create! total_price: params[:total_price], status: "open", created_at: params[:created_at], order_id: params[:id], financial_status: params[:financial_status]
		render :text => "success"
	end

	def order_update
		@store.orders.find_by(order_id: params[:id]).update_attributes! total_price: params[:total_price], status: ("cancelled" if params[:cancelled_at]) || ("closed" if params[:closed_at]) || "open", financial_status: params[:financial_status]
		render :text => "success"
	end

	def customer_create
		@store.customers.create! orders_count: params[:orders_count], created_at: params[:created_at], customer_id: params[:id], total_spent: params[:total_spent]
		render :text => "success"
	end

	def customer_update
		# @store.customers.find_by(customer_id: params[:id]).update_attributes! orders_count: params[:orders_count], total_spent: params[:total_spent]
		render :text => "success"
	end

	def get_store
		@store = Store.find(params[:store_id])
	end

	def verify_webhook
		@data = request.body.read
		hmac_header = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
		digest  = OpenSSL::Digest::Digest.new('sha256')
	    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['shopify_secret'], @data)).strip
	    if calculated_hmac != hmac_header
	    	render :text => "invalid"
	    	return
	    end
	end

end
