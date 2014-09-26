# Use this in web app. Not deletinf file.
module Api
  module V2
    class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
      def facebook

        @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])

        if @user and @user.persisted?
          sign_in @user, :event => :authentication
        end
        redirect_to auth_face_book_api_v2_users_path(user: current_user.to_json.to_s)
      end

      def failure
        render nothing: true
      end
    end
  end
end
