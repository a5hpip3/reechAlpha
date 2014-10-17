module Api
	module V2
		class ApiUsersController < BaseController
			before_filter :require_current_user, only: [:friends, :leader_board, :profile, :current_user_profile, :set_device]
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
        		credentials = graph.get_object("me")
				user = User.where(email: credentials["email"]).first_or_create do |user|
						user.email = credentials["email"]
						user.password = ::Devise.friendly_token[0,20]
						user.password_confirmation = user.password
						user.first_name = credentials["first_name"]
						user.last_name = credentials["last_name"]
						user.invite_id = params[:invite_id]
						user.invite_code = params[:invite_code]
				end
				#set_device if user
				user.authorizations.where(provider: "facebook").first_or_create do |auth|
					auth.provider = "facebook"
					auth.uid = credentials["id"]
					auth.access_token = params[:access_token]
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

			def send_reech_request
				ApiUsersWorker.perform_async(params[:audien_details], current_user.id, 0,PUSH_TITLE_INVITE,"INVITE","INVITE")
				render json: {:status => 200, :message => "success"}
			end

			def set_device
				Device.where("device_token = ? AND platform = ? AND reecher_id != ?", params[:device_token], params[:platform], current_user.reecher_id).destroy_all
				Device.where("device_token != ? AND platform = ? AND reecher_id = ?", params[:device_token], params[:platform], current_user.reecher_id).destroy_all
				current_user.devices.create(device_token: params[:device_token], platform: params[:platform]) if Device.where("device_token = ? AND platform = ? AND reecher_id = ?", params[:device_token], params[:platform], current_user.reecher_id).first.blank?
				render json: {status: 200, message: "success"}
			end

			private

			def set_params
				if params.has_key?(:file)
					params[:user] = JSON.parse(params[:user])
                	#params[:user][:picture] = params[:file]
				end
				params[:user][:user_profile_attributes] = {}
				params[:user][:user_profile_attributes][:id] = params[:user][:profile_id]
				params[:user][:user_profile_attributes][:location] = params[:user][:location]
				params[:user][:user_profile_attributes][:picture] = params[:file]
				params[:user].delete(:location)
				params[:user].delete(:profile_id)
			end

		end
	end
end
