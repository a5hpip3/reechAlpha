module Api
	module V2
		class SessionsController < ::Devise::SessionsController
			respond_to :json

		end
	end
end
