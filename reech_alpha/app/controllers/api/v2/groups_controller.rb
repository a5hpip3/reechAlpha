module Api
  module V2
    class GroupsController < BaseController
      before_filter :require_current_user

      def index
        render json: current_user.owned_groups
      end

    end
  end
end
