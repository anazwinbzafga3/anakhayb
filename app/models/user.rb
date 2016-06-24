class User < ActiveRecord::Base

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	     :recoverable, :rememberable, :trackable, :validatable

	validates_presence_of :name
	has_one :store

	before_save :set_status

	def set_status
		if self.status.blank?
			self.status = "trial"
		end
	end
end
