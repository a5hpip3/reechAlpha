module Api
	module V2
		class ReechChatsController < BaseController
			before_filter :require_current_user

			def index
				@chats = ReechChat.where("solution_id = ?", params[:solution_id]).where("from_user_id = ? OR to_user_id = ?", current_user.id, current_user.id).order('created_at').limit(20)
				render "index"
			end

		end
	end
end
