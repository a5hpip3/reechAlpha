module Api
	module V2
		class SessionsController < ::Devise::SessionsController
			respond_to :json
			before_filter :require_no_authentication, except: :create
			def create

				self.resource = warden.authenticate!({ :scope => resource_name, :recall => "#{controller_path}#failure" })
		    resource.set_device(params[:user][:device]) if resource
		    render json: {success: true, user: resource}
			end

			def failure
				render status: 401, json: {success: false, errors: "Invalid username/ password."}
			end

		end
	end
end
