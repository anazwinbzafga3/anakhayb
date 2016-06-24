class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  ShopifyAPI::Session.setup({:api_key => ENV['shopify_api'], :secret => ENV['shopify_secret']})
  
  protect_from_forgery with: :exception

	def has_store

		if current_user.store
			redirect_to dashboard_path
		end

	end

	def hasnt_store

		if !current_user.store
			redirect_to setup_path
		end

	end

	def after_sign_in_path_for(resource)
		dashboard_path
	end

	def authenticate_admin_user!

		unless current_user.email == "abdelmalek3a@gmail.com"
			redirect_to root_path
		end

	end

	def current_admin_user

		unless current_user.email == "abdelmalek3a@gmail.com"
			current_user
		end

	end
end
