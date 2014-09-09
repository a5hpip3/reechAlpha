class NotifyUsersWorker
	include ApplicationHelper
  include Sidekiq::Worker
  sidekiq_options retry: false
	def perform(entry_id)
    entry = Solution.find(entry_id)
    current_user = entry.wrote_by    
    # send push notification to user who posted this question
    qust_details = entry.forquestion 
    if !qust_details.nil?
    	question_owner = qust_details.user 
    	linked_question = qust_details.linked_questions.find_by_user_id(current_user.reecher_id)
    	linked_by_user = linked_question.linked_by unless linked_question.nil?
    	question_owner_friends = question_owner.friends.pluck(:reecher_id)
    	owner_settings = question_owner.user_settings 
    	check_setting = (owner_settings.pushnotif_is_enabled && owner_settings.notify_question_when_answered)
      check_email_setting = (owner_settings.emailnotif_is_enabled && owner_settings.notify_question_when_answered)
    	if check_email_setting
    		UserMailer.email_question_when_answered(question_owner.email, current_user, qust_details).deliver  unless question_owner.email.blank?
    	end        
      # Send push notification
      if check_setting            
      	device_details = Device.select("device_token,platform").where("reecher_id=?", question_owner.reecher_id.to_s)

      	if ( !linked_question.nil? && (!question_owner_friends.include? current_user.reecher_id))            
      		push_title = "Friend of #{linked_by_user.first_name}" + PUSH_TITLE_PRSLN
      		response_string ="PRSLN,"+ "Friend of <#{linked_by_user.first_name}>" + ","+entry.question_id.to_s
      	elsif question_owner_friends.include? current_user.reecher_id 
          
          response_string ="PRSLN, Your Friend < #{entry.solver} >, #{entry.question_id.to_s},#{Time.now()}"
          push_title = "#{entry.solver}" + PUSH_TITLE_PRSLN          
        elsif ( !linked_question.nil? && (!question_owner_friends.include? linked_by_user.reecher_id))
          
          response_string ="PRSLN, Friend of Friend, #{entry.question_id.to_s} #{Time.now()}"
          push_title = FRIEND_OF_FRIEND + PUSH_TITLE_PRSLN
        else
          
          response_string ="PRSLN, Your Friend , #{entry.question_id.to_s}, #{Time.now().to_s}"
          push_title = "Your Friend" + PUSH_TITLE_PRSLN
        end

        if !device_details.empty?
        	device_details.each do |d|
        		send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s, push_title)
        	end
        end

      end              

      #Send push notification to those who starred this question
      votings = qust_details.votings 
      if !votings.blank?
      	votings.each do |v|             
      		starred_user = v.user             
      		check_setting= (starred_user.user_settings.pushnotif_is_enabled && starred_user.user_settings.notify_when_my_stared_question_get_answer)
      		
      		if check_setting
      			device_details = starred_user.devices.select("device_token,platform") 
      			checkFiendWithStarredUser = Friendship::are_friends(starred_user.reecher_id, entry.solver_id)
      			if checkFiendWithStarredUser
      				response_string = "STARSOLS, Your Friend < #{entry.solver }>, #{entry.question_id.to_s}, #{Time.now().to_s}"
      				push_title = entry.solver+PUSH_TITLE_STARSOLS
      			else
      				response_string = "STARSOLS, Your Friend #{entry.question_id.to_s} #{Time.now().to_s}"
      				push_title = "Friend"+ PUSH_TITLE_STARSOLS
      			end
      			if !device_details.blank?
      				device_details.each do |d|
      					send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s,push_title)
      				end
      			end
            #Send email notification to user who have starred this question
            check_email_setting = (starred_user.user_settings.emailnotif_is_enabled && starred_user.user_settings.notify_when_my_stared_question_get_answer)
            if check_email_setting
            	UserMailer.email_when_my_stared_question_get_answer(starred_user.email,current_user,qust_details).deliver  unless starred_user.email.blank?
            end
          end
        end
      end
    end
  end
end
