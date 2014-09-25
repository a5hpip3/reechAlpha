module Api
	module V2
		class RegistrationsController < ::Devise::RegistrationsController
			respond_to :json

		end
	end
end
