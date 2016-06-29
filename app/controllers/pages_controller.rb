class PagesController < ApplicationController

	include ActionView::Helpers::NumberHelper

	def homepage
		render :layout => 'home'
	end

	def pricing
		render :layout => 'home'
	end

	def demo
		@created_at_min = Date.today - 7.days

		@created_at_max = Date.today

		if params[:created_at_min]
			@created_at_min = Date.parse(params[:created_at_min])
		end

		if params[:created_at_max]
			@created_at_max = Date.parse(params[:created_at_max])
		end

		@currency = "$"

		@store = User.find_by(email: "demo@shopifymetrics.com").store

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

		@time = (Date.parse(@created_at_max.end_of_day.to_s) - Date.parse(@created_at_min.beginning_of_day.to_s)).to_i

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

		render :layout => 'demo'
	end

end
