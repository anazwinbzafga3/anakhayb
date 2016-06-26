class ExportDataJob < ActiveJob::Base
  queue_as :default

  def perform(store)

  	store.update_attributes export_status: "exporting"

    @shop_session = ShopifyAPI::Session.new(store.shop_url, store.token)

	ShopifyAPI::Base.activate_session(@shop_session)

	order_count = ShopifyAPI::Order.count({:status => "any"})

	order_pages = (order_count / 250).ceil + 1

	1.upto(order_pages) do |page|

	  orders = ShopifyAPI::Order.find(:all, params: {page: page , status: 'any' , limit: 250})

	  orders = orders.to_a.map { |order| [order.id,order.financial_status,order.total_price,order.created_at, order.cancelled_at ? "true" : "false" ] }

	  store.orders.import [:order_id,:status,:total_price,:created_at,:cancelled], orders, :validate => false

	end

	customer_count = ShopifyAPI::Customer.count

	customer_pages = (customer_count / 250).ceil + 1

	1.upto(customer_pages) do |page|

	  customers = ShopifyAPI::Customer.find(:all, params: {page: page, limit: 250})

	  customers = customers.to_a.map { |customer| [customer.id,customer.orders_count,customer.total_spent,customer.created_at] }

	  store.customers.import [:customer_id,:orders_count,:total_spent,:created_at], customers, :validate => false

	end

	store.update_attributes export_status: "finished"

  end

end
