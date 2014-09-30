module Api
	module V2
		class RegistrationsController < ::Devise::RegistrationsController
			respond_to :json
			before_filter :set_params, only: [:create]	
			def set_params
      	      if params.has_key?(:picture)
                params[:user] = JSON.parse(params[:user])
                params[:user][:picture] = params[:picture]
              end
            end		
		end
	end
end
