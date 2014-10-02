module Api
  module V2
    class BaseController < CrudController
      acts_as_token_authentication_handler_for User, fallback_to_devise: false

      private
      def require_current_user
				render status: 401, json: {error: "Not authenticated"} unless current_user
			end
    end
  end
end
