class ApiUsersWorker
  include ApplicationHelper
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type)
    user = User.find(user)
    begin
      send_posted_question_notification_to_chosen_emails audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
      send_posted_question_notification_to_chosen_phones audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
    rescue Exception => e
      puts e.backtrace.join("\n")
    end
  end
end