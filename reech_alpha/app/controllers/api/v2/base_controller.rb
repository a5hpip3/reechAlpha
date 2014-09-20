module Api
  module V2
    class BaseController < CrudController

      private
      def require_current_user
				render status: 401, json: {error: "Not authenticated"} unless current_user
			end


    end
  end
end
