class DashboardsController < ApplicationController

	include ActionView::Helpers::NumberHelper

	include ActionView::Helpers::DebugHelper


	before_action :authenticate_user!

	before_action :hasnt_store

	before_action :get_store

	before_action :is_trial?

	before_action :has_data?, only: [:overview]

	def overview

		@created_at_min = Date.today

		@created_at_max = Date.today

		if params[:created_at_min]
			@created_at_min = Date.parse(params[:created_at_min])
		end

		if params[:created_at_max]
			@created_at_max = Date.parse(params[:created_at_max])
		end

		@store = current_user.store

		@orders = @store.orders.where(:created_at => @created_at_min.beginning_of_day..@created_at_max.end_of_day)

		@customers = @store.customers.where(:created_at => @created_at_min.beginning_of_day..@created_at_max.end_of_day)

		@repeated_customers = @orders.count - @customers.count

		@sales = '%.2f' % @orders.inject(0){|sum,e| sum += e.total_price.to_f }

		@sales_formatted = number_to_currency(@sales)

		@refunded = @orders.where(:financial_status => "refunded", :created_at => @created_at_min.beginning_of_day..@created_at_max.end_of_day).count

		@cancelled = @orders.where(:status => "cancelled").count

		@aov = 0

		@rpr = 0

		@pf = 0

		@customer_value = 0

		@clv = 0

		@shop_earliest = @shop.created_at

		@time = (Date.parse(@created_at_max.end_of_day.to_s) - Date.parse(@created_at_min.beginning_of_day.to_s)).to_i

		if @orders.count > 0

			@rpr = '%.2f' % (((@orders.count - @customers.count).to_f / (@customers.count + @repeated_customers)) * 100)

			@pf = '%.2f' % (@orders.count.to_f / (@customers.count + @repeated_customers))

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
