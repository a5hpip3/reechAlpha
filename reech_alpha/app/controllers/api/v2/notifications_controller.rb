class Api::V2::NotificationsController < BaseController
	before_filter :require_current_user
end
