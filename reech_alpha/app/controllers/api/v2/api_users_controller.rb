module Api
	module V2
		class ApiUsersController < BaseController
			before_filter :require_current_user, only: [:friends, :leader_board, :profile]
			before_filter :set_params, only: [:update]
			@model_class = User

			def friends
				#render json: current_user.friends.to_json
				render "friends.json.jbuilder"
			end

			def profile
				@user = User.find(params["id"])
				render "index.json.jbuilder"
			end

			def leader_board
				render json: {current_user: current_user, top: (User.where(id: current_user.friends.pluck(:id) << current_user.id).order("#{params[:board_type]}_position DESC").limit(5))}
			end
      # Auth for facebook.
			def auth_face_book
				user = User.where(email: params[:email]).first_or_create do |user|
						user.provider = "facebook"
						user.uid = params[:uid]
						user.email = params[:email]
						user.password = ::Devise.friendly_token[0,20]
						user.first_name = params[:first_name]
						user.last_name = params[:last_name]
				end
				# Pending update profile and make connections.
				render json: user
			end

			private

			def set_params
				if params.has_key?(:file)
					params[:user] = JSON.parse(params[:user])
                	params[:user][:picture] = params[:file]
				end
				params[:user][:user_profile_attributes] = {}
				params[:user][:user_profile_attributes][:location] = params[:user][:location]
			end

		end
	end
end
