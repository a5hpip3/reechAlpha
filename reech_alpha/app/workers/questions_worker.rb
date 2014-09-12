class QuestionsWorker
  include ApplicationHelper
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(action, audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type)
    begin
      user = User.find(user)
      question = Question.find(question)
      if action == "link_questions_to_expert"
        link_questions_to_expert_for_users audien_details, user, question.question_id
        send_posted_question_notification_to_chosen_emails audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
        send_posted_question_notification_to_chosen_phones audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
      else
        send_posted_question_notification_to_reech_users audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
        send_posted_question_notification_to_chosen_emails audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
        send_posted_question_notification_to_chosen_phones audien_details, user, question, push_title_msg, push_contant_str, linked_quest_type
      end
    rescue Exception => e
      puts e.backtrace.join("\n")
    end
  end

  def link_questions_to_expert_for_users audien_details ,user,question_id
      reecher_ids = audien_details["reecher_ids"]
      if !reecher_ids.blank?
        puts "enters"
        User.where(reecher_id: reecher_ids).each do |audien_user|
          puts "enters loop"
          if !audien_user.linked_with_question?(question_id, user)
            audien_user.linked_questions.create(question_id: question_id, linked_by_uid: user.reecher_id, email_id: audien_user.email, phone_no: audien_user.phone_number,:linked_type=>'LINKED')
            if audien_user.has_email_notifications_enabled?("LINKED")
              @question = Question.find_by_question_id(question_id)
              puts "email"
              UserMailer.email_linked_to_question(audien_user.email, user, @question).deliver  unless audien_user.email.blank?
              notify_string ="LINKED,"+ "<" + user.full_name + ">" + ","+ question_id.to_s + "," +Time.now().to_s
              audien_user.devices.each do |d|
                send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+PUSH_TITLE_LINKED)
              end
            end
          end
        end
      end
  end

  def send_posted_question_notification_to_reech_users audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
      reecher_ids = audien_details["reecher_ids"]
      @post_quest_to_frnd =[]
      if(!audien_details.blank? && audien_details.has_key?("reecher_ids") && !audien_details["reecher_ids"].empty?)
        User.where(reecher_id: reecher_ids).each do |audien_user|
          pqtf = PostQuestionToFriend.create(user_id: user.reecher_id, friend_reecher_id: audien_user.reecher_id, question_id: question.question_id)
          @post_quest_to_frnd << pqtf.id
          if audien_user.has_device_notifications_enabled?("ASK")
            notify_string = push_contant_str + "," + "<"+user.full_name + ">" + "," + question.question_id.to_s + "," + Time.now().to_s
            Device.where(reecher_id: audien_user.reecher_id).each do |d|
              send_device_notification(d.device_token.to_s, notify_string, d.platform.to_s, user.full_name+push_title_msg)
            end
          end

          if audien_user.has_email_notifications_enabled?("ASK")
            UserMailer.send_question_details_to_audien(audien_user.email, audien_user.first_name,question, user).deliver if audien_user.email !=nil
          end
        end
      end
  end

end
