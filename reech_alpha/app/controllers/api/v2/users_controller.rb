module Api
  module V2
    class UsersController < BaseController
      before_filter :require_current_user, only: [:friends, :leader_board, :profile]


      def friends
        #render json: current_user.friends.to_json
        render "friends.json.jbuilder"
      end
      def profile
        render "index.json.jbuilder"
      end
      def leader_board
        render json: {current_user: current_user, top: (User.where(id: current_user.friends.pluck(:id) << current_user.id).order("#{params[:board_type]}_position DESC").limit(5))}
      end

    end
  end
end
