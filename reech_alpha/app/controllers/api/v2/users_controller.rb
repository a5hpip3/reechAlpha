module Api
  module V2
    class UsersController < BaseController
      def friends
        render json: current_user.friends.to_json
      end
    end
  end
end
