module Api
  module V2
    class GroupsController < BaseController
      before_filter :require_current_user

      def index
      	@groups = current_user.owned_groups
        render "index.json.jbuilder"
      end

    end
  end
end
