class DashboardsController < ApplicationController

	include ActionView::Helpers::NumberHelper

	include ActionView::Helpers::DebugHelper


	before_action :authenticate_user!

	before_action :hasnt_store

	before_action :get_store

	before_action :is_trial?

	before_action :has_data?, only: [:overview]

	def overview

		# cycle = 0

		@created_at_min = Date.today

		@created_at_max = Date.tomorrow

		if params[:created_at_min]
			@created_at_min = params[:created_at_min]
		end

		if params[:created_at_max]
			@created_at_max = params[:created_at_max]
		end

		# order_count = ShopifyAPI::Order.count({:status => "any", :created_at_min => @created_at_min,created_at_max: @created_at_max})

		# order_pages = (order_count / 250).ceil + 1

		# start_time = Time.now

		# @orders = []

		# if order_count > 250

		# 	1.upto(order_pages) do |page|
		# 	  unless page == 1
		# 	    stop_time = Time.now
		# 	    processing_duration = stop_time - start_time
		# 	    wait_time = (cycle - processing_duration).ceil
		# 	    sleep wait_time if wait_time > 0
		# 	    start_time = Time.now
		# 	  end
		# 	  @orders += ShopifyAPI::Order.find(:all, params: { created_at_min: @created_at_min,created_at_max: @created_at_max, page: page , status: 'any' , limit: 250 }).to_a

		# 	end

		# else
		# 	@orders += ShopifyAPI::Order.find(:all, params: { created_at_min: @created_at_min,created_at_max: @created_at_max , status: 'any' , limit: 250 })
		# end

		# @customers = []

		# customer_count = ShopifyAPI::Customer.count({:created_at_min => @created_at_min,created_at_max: @created_at_max})

		# customer_pages = (customer_count / 250).ceil + 1

		# start_time = Time.now

		# if customer_count > 250

		# 	1.upto(customer_pages) do |page|
		# 	  unless page == 1
		# 	    stop_time = Time.now
		# 	    processing_duration = stop_time - start_time
		# 	    wait_time = (cycle - processing_duration).ceil
		# 	    sleep wait_time if wait_time > 0
		# 	    start_time = Time.now
		# 	  end
		# 	  @customers += ShopifyAPI::Customer.find(:all, params: { created_at_min: @created_at_min,created_at_max: @created_at_max, page: page , limit: 250 }).to_a

		# 	end

		# else
		# 	@customers += ShopifyAPI::Customer.find(:all, params: { created_at_min: @created_at_min,created_at_max: @created_at_max , limit: 250 })
		# end

		# @customers.delete_if do |customer|
		# 	if !customer.last_order_id
		# 		true
		# 	end
		# end

		# @sales = '%.2f' % @orders.inject(0){|sum,e| sum += e.total_price.to_f }

		# @sales_formatted = number_to_currency(@sales)

		# @refunded = ShopifyAPI::Order.count({:financial_status => "refunded", :created_at_min => @created_at_min,created_at_max: @created_at_max})

		# @cancelled = ShopifyAPI::Order.count({:status => "cancelled", :created_at_min => @created_at_min,created_at_max: @created_at_max})

		# @repeated_customers = @orders.count - @customers.count

		# @aov = 0

		# @rpr = 0

		# @pf = 0

		# @customer_value = 0

		# @clv = 0

		# @shop_earliest = @shop.created_at

		# @time = (Date.parse(@created_at_max.to_s) - Date.parse(@created_at_min.to_s)).to_i

		# if @orders.count > 0

		# 	@rpr = '%.2f' % (((@orders.count - @customers.count).to_f / @customers.count) * 100)

		# 	@pf = '%.2f' % (@orders.count.to_f / @customers.count)

		# 	@aov = '%.2f' % (@sales.to_f / @orders.count)

		# 	@customer_value = '%.2f' % (@aov.to_f * @pf.to_f)

		# 	@clv = @customer_value.to_f * 2

		# 	@aov = number_to_currency(@aov)

		# 	@customer_value = number_to_currency(@customer_value)

		# 	@clv = number_to_currency(@clv)
		# end

		# today = Date.today

		# @since = 1

		# @until = 1

		# if params[:created_at_min]
		# 	@since = (Date.parse(@created_at_min) - today).to_i
		# end

		# if params[:created_at_max]
		# 	@since = (Date.parse(@created_at_max) - today).to_i
		# end

		@store = current_user.store

		@orders = @store.orders.where(:created_at => @created_at_min..@created_at_max)

		@customers = @store.customers.where(:created_at => @created_at_min..@created_at_max)

		@repeated_customers = @orders.count - @customers.count

		@sales = '%.2f' % @orders.inject(0){|sum,e| sum += e.total_price.to_f }

		@sales_formatted = number_to_currency(@sales)

		@refunded = @orders.where(:status => "refunded", :created_at => @created_at_min..@created_at_max).count

		@cancelled = @orders.where(:cancelled => "true").count

		@aov = 0

		@rpr = 0

		@pf = 0

		@customer_value = 0

		@clv = 0

		@shop_earliest = @shop.created_at

		@time = (Date.parse(@created_at_max.to_s) - Date.parse(@created_at_min.to_s)).to_i

		if @orders.count > 0

			@rpr = '%.2f' % (((@orders.count - @customers.count).to_f / @customers.count) * 100)

			@pf = '%.2f' % (@orders.count.to_f / @customers.count)

			@aov = '%.2f' % (@sales.to_f / @orders.count)

			@customer_value = '%.2f' % (@aov.to_f * @pf.to_f)

			@clv = @customer_value.to_f * 2

			@aov = number_to_currency(@aov)

			@customer_value = number_to_currency(@customer_value)

			@clv = number_to_currency(@clv)
		end

		render :layout => 'dashboard'


	end

	def exporting
		if current_user.store.export_status == "finished"
			redirect_to dashboard_path
			return
		end
		render :layout => 'dashboard'
	end

	def exporting_status
		if request.xhr?
			respond_to do |format|
				format.json 
			end
		else
			redirect_to root_path
		end
	end

	def get_store

		@store = current_user.store

		@shop_session = ShopifyAPI::Session.new(@store.shop_url, @store.token)

		ShopifyAPI::Base.activate_session(@shop_session)

		@shop = ShopifyAPI::Shop.current


	end

	def is_trial?

		if current_user.status == "trial_ended"
			redirect_to payment_path
		end

	end

	def has_data?

		if current_user.store.export_status != "finished"
			redirect_to exporting_path
		end

	end




end
