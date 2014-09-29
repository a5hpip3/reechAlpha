module Api
	module V2
		class ApiUsersController < BaseController
			before_filter :require_current_user, only: [:friends, :leader_board, :profile, :current_user_profile]
			before_filter :set_params, only: [:update]
			@model_class = User

			def friends
				#render json: current_user.friends.to_json
				render "friends.json.jbuilder"
			end

			def profile
				# Use this for fetching other user's profile
				@user = User.find(params["id"])
				render "index.json.jbuilder"
			end

			def current_user_profile
				@user = current_user
				render "index.json.jbuilder"
			end

			def leader_board
				render json: {current_user: current_user, top: (User.where(id: current_user.friends.pluck(:id) << current_user.id).order("#{params[:board_type]}_position DESC").limit(5))}
			end
      # Auth for facebook.
			def auth_face_book
				graph = Koala::Facebook::API.new(params[:access_token])
        logger.info "Facebook credential -----------------------#{graph.inspect}"
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

			def validate_code
				user_ref =InviteUser.where("referral_code = ? AND token_validity_time >= ? AND status =1", params[:code] ,Time.now).first
				if user_ref || (params[:code] == 1111.to_s)
					render json: {is_valid: true, invite_id: user_ref ? user_ref.id : ""}
				else
					render json: {is_valid: false}
				end
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
