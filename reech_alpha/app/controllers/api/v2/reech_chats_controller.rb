module Api
	module V2
		class ReechChatsController < BaseController
			before_filter :require_current_user

			def index
				@chats = ReechChat.where("solution_id = ?", params[:solution_id]).where("from_user_id in (?) AND to_user_id in (?)", params[:member_ids], params[:member_ids]).order('created_at').limit(20)
				render "index"
			end

		end
	end
end
