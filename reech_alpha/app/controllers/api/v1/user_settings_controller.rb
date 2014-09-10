module Api
	module V1
		class UserSettingsController < ApiController
			before_filter :restrict_access
			respond_to :json

			def view_settings
				msg = {:status => 200, :settings => current_user.user_settings }
				render :json => msg
			end

			def update_settings
				user_settings = current_user.user_settings
				user_settings.location_is_enabled = params[:location]
				user_settings.pushnotif_is_enabled = params[:push_notification]
				user_settings.emailnotif_is_enabled = params[:email]
				user_settings.notify_question_when_answered = params[:question_has_answer]
				user_settings.notify_linked_to_question = params[:linked_question]
				user_settings.notify_solution_got_highfive = params[:high5]
				user_settings.notify_audience_if_ask_for_help = params[:ask_for_help]
				user_settings.notify_when_someone_grab_my_answer = params[:grab_my_sol]
				user_settings.notify_when_my_stared_question_get_answer = params[:starred_quest_answer]
				user_settings.save
				msg = {:status => 200, :settings => current_user.user_settings }
				render :json => msg
			end



		end
	end
end
