class ExportDataJob < ActiveJob::Base
  queue_as :default

  def perform(store)

    @shop_session = ShopifyAPI::Session.new(store.shop_url, store.token)

	ShopifyAPI::Base.activate_session(@shop_session)

	if Rails.env.production?

  	ShopifyAPI::Webhook.create({ topic: "orders/create", address: "http://shopifymetrics.com/webhooks/orders/create/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "orders/updated", address: "http://shopifymetrics.com/webhooks/orders/update/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "customers/create", address: "http://shopifymetrics.com/webhooks/customers/create/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "customers/update", address: "http://shopifymetrics.com/webhooks/customers/update/#{store.id}"})

  	else

  	ShopifyAPI::Webhook.create({ topic: "orders/create", address: "http://df0de420.ngrok.io/webhooks/orders/create/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "orders/updated", address: "http://df0de420.ngrok.io/webhooks/orders/update/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "customers/create", address: "http://df0de420.ngrok.io/webhooks/customers/create/#{store.id}"})

	ShopifyAPI::Webhook.create({ topic: "customers/update", address: "http://df0de420.ngrok.io/webhooks/customers/update/#{store.id}"})

	end

	store.update_attributes export_status: "exporting"

	order_count = ShopifyAPI::Order.count({:status => "any"})

	order_pages = (order_count / 250).ceil + 1

  wait_cycle = 0.5

  start_time = Time.now

	1.upto(order_pages) do |page|

    unless page == 1
      stop_time = Time.now
      processing_duration = stop_time - start_time
      wait_time = (wait_cycle - processing_duration).ceil
      sleep wait_time if wait_time > 0
      start_time = Time.now
    end

	  orders = ShopifyAPI::Order.find(:all, params: {page: page , status: 'any' , limit: 250})

	  orders = orders.to_a.map { |order| [order.id,order.total_price,order.created_at,order.financial_status, ("cancelled" if order.cancelled_at) || ("closed" if order.closed_at) || "open"] }

	  store.orders.import [:order_id,:total_price,:creation_date,:financial_status,:status], orders, :validate => false

	end

	customer_count = ShopifyAPI::Customer.count

	customer_pages = (customer_count / 250).ceil + 1

  start_time = Time.now

	1.upto(customer_pages) do |page|

    unless page == 1
      stop_time = Time.now
      processing_duration = stop_time - start_time
      wait_time = (wait_cycle - processing_duration).ceil
      sleep wait_time if wait_time > 0
      start_time = Time.now
    end

	  customers = ShopifyAPI::Customer.find(:all, params: {page: page, limit: 250})

	  customers = customers.to_a.map { |customer| [customer.id,customer.orders_count,customer.total_spent,customer.created_at] }

	  store.customers.import [:customer_id,:orders_count,:total_spent,:creation_date], customers, :validate => false

	end

	store.update_attributes export_status: "finished"

  end

end
