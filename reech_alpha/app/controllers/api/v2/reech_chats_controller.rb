module Api
	module V2
		class ReechChatsController < BaseController
			before_filter :require_current_user

			def index
				@chats = current_user.chats(params[:solution_id])
				render "index"
			end
		end
	end
end
