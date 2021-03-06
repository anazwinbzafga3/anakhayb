class DashboardsController < ApplicationController

	include ActionView::Helpers::NumberHelper

	include ActionView::Helpers::DebugHelper


	before_action :authenticate_user!

	before_action :hasnt_store

	before_action :get_store

	before_action :is_trial?

	before_action :has_data?, only: [:overview]

	def overview

		@created_at_min = Date.today - 7.days

		@created_at_max = Date.today

		if params[:created_at_min]
			@created_at_min = Date.parse(params[:created_at_min])
		end

		if params[:created_at_max]
			@created_at_max = Date.parse(params[:created_at_max])
		end

		@currency = @store.currency

		@shop_earliest = @store.currency

		@orders = @store.orders.where(:creation_date => @created_at_min.beginning_of_day..@created_at_max.end_of_day)

		@customers = @store.customers.where(:creation_date => @created_at_min.beginning_of_day..@created_at_max.end_of_day, :orders_count => 1..Float::INFINITY)

		@repeated_customers = @orders.length - @customers.length

		@sales = '%.2f' % @orders.inject(0){|sum,e| sum += e.total_price.to_f }

		@sales_formatted = number_to_currency(@sales, unit: @currency)

		@refunded = @orders.to_a.select { |order| order.financial_status == "refunded" }.length

		@cancelled = @orders.to_a.select { |order| order.status == "cancelled" }.length

		@aov = 0

		@rpr = 0

		@pf = 0

		@customer_value = 0

		@clv = 0

		# @time = (Date.parse(@created_at_max.end_of_day.to_s) - Date.parse(@created_at_min.beginning_of_day.to_s)).to_i

		if @orders.length > 0

			@rpr = '%.2f' % (((@orders.length - @customers.length).to_f / (@customers.length + @repeated_customers)) * 100)

			@pf = '%.2f' % (@orders.length.to_f / @customers.length)

			@aov = '%.2f' % (@sales.to_f / @orders.length)

			@customer_value = '%.2f' % (@aov.to_f * @pf.to_f)

			@clv = @customer_value.to_f * 2

			@aov = number_to_currency(@aov, unit: @currency)

			@customer_value = number_to_currency(@customer_value, unit: @currency)

			@clv = number_to_currency(@clv, unit: @currency)

		end
		@data = {
			sales: @sales_formatted,
			orders: @orders.length,
			new_customers: @customers.length,
			repeated_customers: @repeated_customers,
			aov: @aov,
			rpr: @rpr,
			pf: @pf,
			refunded_orders: @refunded,
			cancelled_orders: @cancelled,
			customer_value: @customer_value,
			clv: @clv
		}
		respond_to do |format|
			format.json {
				render :json => @data
				return
			}
			format.html {
				render :layout => 'dashboard'
			}
		end


	end

	def exporting
		if current_user.store.export_status == "finished"
			redirect_to dashboard_path(:first_visit => true)
			return
		end
		render :layout => 'dashboard'
	end

	def get_store

		@store = current_user.store


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
