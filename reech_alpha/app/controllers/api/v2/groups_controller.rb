module Api
  module V2
    class GroupsController < BaseController
      before_filter :require_current_user

      def index
      	render "index.json.jbuilder"
      end

      def associate_user_to_group
        user = User.find_by_reecher_id(params[:associated_user_id])
        if current_user.friends.include? user
          user.groups = user.groups - current_user.owned_groups + current_user.owned_groups.where(id: params[:group_id])
          msg = {:status => 200, :message => "User is Associated to the  groups",:group_ids=>params[:group_id] }
        else
          msg = {:status => 403, :message => "Asoociate not a friend",:group_ids=>params[:group_id] }
        end
        render json: msg
      end

    end
  end
end
