class StoresController < ApplicationController

	before_action :authenticate_user!
	before_action :has_store, except: [:payment,:create_payment,:activate_payment,:export_data]
	before_action :has_paid?, only: [:payment,:create_payment,:activate_payment]

	 skip_before_action :verify_authenticity_token, only: [:activate_payment]

	def new

		@store = User.find(current_user.id).build_store

		render :layout => "signup"

	end

	def create

		@store = User.find(current_user.id).build_store

		session = ShopifyAPI::Session.new(params[:store][:shop_url])

		scope = ["read_products","read_orders","read_customers","read_analytics"]

		permission_url = session.create_permission_url(scope, authorize_url)

		redirect_to permission_url

	end

	def authorize

		@store = User.find(current_user.id).build_store

		@store.user_id = current_user.id

		@store.code = params[:code]

		@store.shop_url = params[:shop]

		data = { "client_id" => ENV['shopify_api'], "client_secret" => ENV['shopify_secret'], "code" => @store.code}

		request = Net::HTTP.post_form(URI.parse('https://' + @store.shop_url + '/admin/oauth/access_token'), data)

		@store.token = JSON.parse(request.body)['access_token']

		@shop_session = ShopifyAPI::Session.new(@store.shop_url, @store.token)

		ShopifyAPI::Base.activate_session(@shop_session)

		@shop = ShopifyAPI::Shop.current

		@store.name = @shop.name

		@store.shop_earliest = @shop.created_at

		@store.currency = @shop.money_format.chomp(" {{amount}}")

		if @store.save!

			ExportDataJob.perform_later @store

			redirect_to exporting_path

		end

	end

	def payment
		render :layout => "signup"
	end

	def create_payment

		@store = current_user.store

		@shop_session = ShopifyAPI::Session.new(@store.shop_url, @store.token)

		ShopifyAPI::Base.activate_session(@shop_session)

		created_at_min = Date.today - 30.days

		created_at_max = Date.today

		order_count = ShopifyAPI::Order.count({:status => "any", :created_at_min => created_at_min,created_at_max: created_at_max})

		order_pages = (order_count / 250).ceil + 1

		orders = []

		if order_count > 250

			1.upto(order_pages) do |page|

			  orders += ShopifyAPI::Order.find(:all, params: { created_at_min: created_at_min,created_at_max: created_at_max, page: page , status: 'any' , limit: 250 }).to_a

			end

		else

			orders += ShopifyAPI::Order.find(:all, params: { created_at_min: created_at_min,created_at_max: created_at_max , status: 'any' , limit: 250 })

		end

		price = 0

		sales = '%.2f' % orders.inject(0){|sum,e| sum += e.total_price.to_f }

		sales = sales.to_f

		case
		when sales < 2500
			price = 35
		when sales < 10000
			price = 60
		when sales < 50000
			price = 120
		when sales < 200000
			price = 240
		end


		@response = ShopifyAPI::RecurringApplicationCharge.create({
			"price": price,
			"name": "Shoipfy Metrics Account",
			"return_url": activate_payment_url
		});

		redirect_to @response.confirmation_url

	end

	def activate_payment

		charge_id = params[:charge_id]

		@response = ShopifyAPI::RecurringApplicationCharge.find(charge_id).activate();

		if @response
			current_user.status = "paid"
			current_user.save!
			redirect_to dashboard_path
		end

	end

	def export_data

		@store = current_user.store

		@shop_session = ShopifyAPI::Session.new(@store.shop_url, @store.token)

		ShopifyAPI::Base.activate_session(@shop_session)

		@shop = ShopifyAPI::Shop.current

	end

	protected

	def has_paid?
		if current_user.status != "trial_ended"
			redirect_to dashboard_path
			return
		end
	end

end
