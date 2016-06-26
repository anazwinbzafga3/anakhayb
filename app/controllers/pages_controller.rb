class PagesController < ApplicationController

	def homepage
		render :layout => 'home'
	end

	def pricing
		render :layout => 'home'
	end

	def export_data

		ExportDataJob.perform_later current_user.store

	end

end
