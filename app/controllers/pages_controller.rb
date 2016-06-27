class PagesController < ApplicationController

	include ActionView::Helpers::NumberHelper

	def homepage
		render :layout => 'home'
	end

	def pricing
		render :layout => 'home'
	end

	def demo
		@created_at_min = Date.today

		@created_at_max = Date.today

		if params[:created_at_min]
			@created_at_min = Date.parse(params[:created_at_min])
		end

		if params[:created_at_max]
			@created_at_max = Date.parse(params[:created_at_max])
		end

		@store = User.find_by(email: "demo@shopifymetrics.com").store

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

end
