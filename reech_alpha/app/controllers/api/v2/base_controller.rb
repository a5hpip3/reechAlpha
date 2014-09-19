module Api
  module V2
    class BaseController < CrudController

      private
      def require_current_user
				render status: 401, json: {error: "Not authenticated"} unless current_user
			end

			def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end
    end
  end
end
