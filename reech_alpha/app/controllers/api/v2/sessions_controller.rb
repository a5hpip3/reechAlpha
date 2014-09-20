module Api
	module V2
		class SessionsController < ::Devise::SessionsController
			respond_to :json

			def create
				self.resource = warden.authenticate!({ :scope => resource_name, :recall => "#{controller_path}#failure" })
		    sign_in(resource_name, resource)
		    render json: {success: true, user: resource}
			end

			def failure
				render status: 401, json: {success: false, errors: "Invalid username/ password."}
			end

		end
	end
end
