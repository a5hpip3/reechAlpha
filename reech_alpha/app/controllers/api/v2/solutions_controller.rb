module Api
  module V2
    class SolutionsController < BaseController
    	before_filter :require_current_user
    	after_filter :send_notification, only: [:create]

    	private

    	def send_notifications
    		Notification.create(from_user: current_user.reecher_id, to_user: entry.question.posted_by_uid, message: "You got a solution for your question.", notification_type: "SOLUTION", record_id: entry.question.id)
    	end
    end
  end
end
