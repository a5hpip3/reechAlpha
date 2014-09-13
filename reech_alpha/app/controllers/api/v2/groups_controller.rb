module Api
  module V2
    class GroupsController < BaseController

      def index
        render json: current_user.owned_groups
      end
      
    end
  end
end
