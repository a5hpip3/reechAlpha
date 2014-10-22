class SolutionWorker
  include ApplicationHelper
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(from_user, to_user, message, notification_type, record_id)
    solution = Solution.find(record_id)
    user = User.find_by_reecher_id(to_user)
    from = User.find_by_reecher_id(from_user)
    Notification.create(from_user: from_user, to_user: to_user, message: message, notification_type: notification_type, record_id: solution.question.id)
    begin
      send_device_notification(user.devices.first.device_token, message, user.devices.first.platform, message) if user.has_device_notifications_enabled?(notification_type)
      if notification_type == "GRABSOL" && user.has_email_notifications_enabled?(notification_type)
        UserMailer.email_when_someone_grab_my_answer(user.email, from, solution.body).deliver
      elsif notification_type == "HI5" && user.has_email_notifications_enabled?(notification_type)
        UserMailer.email_solution_got_highfive(user.email, from, solution.body).deliver
      end
    rescue Exception => e
      puts e.backtrace.join("\n")
    end
  end
end