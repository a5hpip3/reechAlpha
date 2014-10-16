module ApplicationHelper
 
  def message_person(mailbox_name, message)
    mailbox_name == 'inbox' ? message.sender : message.recipient_list.join(', ')
  end

  def send_device_notification device_token,message,platform,title="Title"          
    if platform == 'iOS'      
      n1= APNS::Notification.new(device_token, :alert => title, :badge => 1, :sound => 'default',:other=>{:message=>message,:title=>title,:badge => 1})
      APNS.send_notifications([n1])    
    elsif platform =='Android'      
      require 'gcm'
      gcm = GCM.new("AIzaSyC98sLFibOitkGdBjGPfQTWfLochak7v6E")
      registration_ids= [device_token] # an array of one or more client registration IDs
      options = {data: {payload_body:message ,message: title ,title:"Reech"}, collapse_key: "Reech",time_to_live:3600}
      response = gcm.send_notification(registration_ids, options)      
    end
  end

  def check_notify_question_when_answered user_id
    #UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
     if ((setting[:pushnotif_is_enabled] == true ) && (setting[:notify_question_when_answered] == true))
     check =true
    else
     check =false
    end
    check 
  end

  def notify_linked_to_question user_id
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_linked_to_question] == true))
      check =true
    else
       check =false
    end
    check
  end

 def check_push_notification_enable user_id
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if (setting[:pushnotif_is_enabled]== true) 
      check =true
    else
       check =false
    end
    check
  end
   
  def notify_when_my_stared_question_get_answer user_id
    puts "notify_when_my_stared_question_get_answer==#{user_id}"
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_when_my_stared_question_get_answer] == true))
      check =true
    else
       check =false
    end
    check
  end
  
  def notify_solution_got_highfive user_id
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_solution_got_highfive] == true))
      check =true
    else
      check =false
    end
    check
  end
  
  
  def notify_audience_if_ask_for_help user_id
     user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_audience_if_ask_for_help] == true))
      check =true
    else
      check =false
    end
    check
    
  end
  
  def notify_when_someone_grab_my_answer user_id
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
      setting  = setting[0]
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_when_someone_grab_my_answer] == true))
      check =true
    else
      check =false
    end
     puts "EMAIL-notify_when_someone_grab_my_answer=#{check}"
    check
 end
  
  # Start method for email notification 
  
  def check_email_question_when_answered user_id
    #UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
     puts "setting===#{setting.inspect}"
     if ((setting[:emailnotif_is_enabled] == true) && (setting[:notify_question_when_answered] == true))
     check =true
    else
     check =false
    end
    
    puts "EMAIL-check_email_question_when_answered=#{check}"
    check 
  end

  def check_email_linked_to_question user_id
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(user_id)
    setting =UserSettings.where("reecher_id=?",user.reecher_id)
    setting  = setting[0]
    if ((setting[:emailnotif_is_enabled]== true) && (setting[:notify_linked_to_question] == true))
      check =true
    else
       check =false
    end
    check
  end

   
  def check_email_when_my_stared_question_get_answer user_id
    puts "check_email_when_my_stared_question_get_answer==#{user_id}"
    user = User.find_by_reecher_id(user_id)
    setting =UserSettings.where("reecher_id=?",user.reecher_id)
    setting  = setting[0]
    if ((setting[:emailnotif_is_enabled]== true) && (setting[:notify_when_my_stared_question_get_answer] == true))
      check =true
    else
       check =false
    end
    check
  end
  
  def check_email_solution_got_highfive user_id
    user = User.find_by_reecher_id(user_id)
    setting =UserSettings.where("reecher_id=?",user.reecher_id)
    setting  = setting[0]
    if ((setting[:emailnotif_is_enabled]== true) && (setting[:notify_solution_got_highfive] == true))
      check =true
    else
      check =false
    end
    puts "EMAIL-check_email_solution_got_highfive=#{check}"
    check
  end
  
  
  def check_email_audience_if_ask_for_help user_id
    puts "user_idAAAAAAAAAAAAAAA=#{user_id}"
    user = User.find_by_reecher_id(user_id)
    setting =UserSettings.where("reecher_id=?",user.reecher_id)
    setting  = setting[0]
    puts "setting7888881212321321==#{setting.inspect}"
    if ((setting[:emailnotif_is_enabled]== true) && (setting[:notify_audience_if_ask_for_help] == true))
      check =true
    else
      check =false
    end
    puts "EMAIL-check_email_audience_if_ask_for_help=#{check}"
    check
    
  end
  
  def check_email_when_someone_grab_my_answer user_id
    user = User.find_by_reecher_id(user_id)
     setting =UserSettings.where("reecher_id=?",user.reecher_id)
     setting  = setting[0]
    if ((setting[:emailnotif_is_enabled]== true) && (setting[:notify_when_someone_grab_my_answer] == true))
      check =true
    else
      check =false
    end
     puts "EMAIL-check_email_question_when_answered=#{check}"
    check
 end
  
  
  
  # End of method for email notification
  
  
  
  def get_curio_points user_id
  @user1 = User.find_by_reecher_id(user_id)
  points = @user1.points
  
  end
  
  def get_user_total_question user_id
  @user2 = User.find_by_reecher_id(user_id)
  tot_question = @user2.questions.size
  end
  
  def get_user_total_solution user_id
  sols = Solution.where(:solver_id=>user_id)
  tot_sol = sols.size
  end
  
  def get_user_total_connection user_id
  puts "CONNECTION  ==#{user_id}"    
  @user4 = User.find_by_reecher_id(user_id)
  tot_question = @user4.friendships.where('status = "accepted"').size
  
  end
  
  def make_friendship_standard(friends, user)
  # Proceed only if both the IDs are not same 

    puts "friends====#{friends}"
    puts "user-recher_id====#{user}"
    if friends != user
      are_friends1 = Friendship::are_friends(friends,user)
      are_friends2 = Friendship::are_friends(user,friends)

      if !are_friends1
        friend =  Friendship.new()
        friend.reecher_id = friends
        friend.friend_reecher_id = user
        friend.status = "accepted"
        friend.save
      end
      if !are_friends2
        friend2 =  Friendship.new()
        friend2.reecher_id = user
        friend2.friend_reecher_id = friends
        friend2.status = "accepted"
        friend2.save
      end
      return true
    else
      puts "Error : Cant make friendship between same users." 
      return false
    end
  end  
  
  def filter_phone_number phone_number  
    puts "filter_phone_number has received phone_number===#{phone_number}" 
    phone_number.strip
    check_plus_sign= phone_number.chr
    phone_num      =  phone_number.gsub(/[^0-9]/, '') # Only numeric value
    first_num      = phone_num[0,1]
    first_two_num  = phone_num[0,2]
   if check_plus_sign == "+"      
      # Phone number start with + sign Block
      if (first_num == "1" && (phone_num[1,(phone_num.size-1)]).size == 10)
        # check first number is start with +1 and phone number size is 10 except country code(1) then add +1
        phone_num = "+"+phone_num
      elsif (first_two_num == "91" && (phone_num[2,(phone_num.size-2)]).size ==10)
       # check first two number is start with +91 and phone number size is 10 except country code(91) then add +
        phone_num = "+"+phone_num
      elsif (first_num != "1" && phone_num.size == 10)
       # check first number is not start with +1 and phone number size is 10 except country code(1) then add +1
        phone_num = "+1"+phone_num
      end 
    # Phone number Start with 00 block   
   elsif (first_two_num =="00" && (phone_num[2,(phone_num.size-2)]).size ==10)
      # Starat with 00 
      if phone_num[2,1] == "1"
      phone_num =  "+1"+ phone_num   
      elsif (phone_num[2,2] == "91" && (phone_num[2,(phone_num.size-2)]).size ==10)
      phone_num = "+"+phone_num
      end
   elsif ( (check_plus_sign != "+" && phone_num.size == 10) && (INDIAN_PHONE_NUMBER_ALLOWED.include? phone_num))
     phone_num = "+91"+phone_num
   elsif ( (check_plus_sign != "+" && phone_num.size == 10) && (!(INDIAN_PHONE_NUMBER_ALLOWED.include? phone_num)))
     phone_num = "+1"+phone_num  
   elsif ( (check_plus_sign != "+" && first_num =="1"  && phone_num.size == 11) && (!(INDIAN_PHONE_NUMBER_ALLOWED.include? phone_num)))
     phone_num = "+"+phone_num  
   elsif ( (check_plus_sign != "+" && first_num =="9" && first_two_num=="91" && (phone_num[2,(phone_num.size-2)]).size ==10) )
     phone_num = "+"+phone_num      
   end
    puts "FINAL-NUMBER==#{phone_num}"
    phone_num
  end  

  
  def linked_question_with_type linker_id,user_id="",question_id, email,phone,linked_type_str     
             @linkquest = LinkedQuestion.new()
             @linkquest.user_id =user_id
             @linkquest.question_id = question_id
             @linkquest.linked_by_uid = linker_id
             @linkquest.email_id = email
             @linkquest.phone_no = phone
             @linkquest.linked_type = linked_type_str
             @linkquest.save
             rand_str = (('A'..'Z').to_a + (0..9).to_a)
             token = (0...32).map { |n| rand_str.sample }.join
             referral_code = (0...8).map { |n| rand_str.sample }.join
             validity= 15.days.from_now
             tries = 0
             invite_user_object= InviteUser.create(:linked_question_id=>@linkquest.id,:token=>token,:referral_code=>referral_code,:token_validity_time =>validity)
        
          arr =[]
          arr.push(:referral_code=>referral_code)  
          arr.push(:token=>token)
          puts "arrarrarrarrarr=#{arr.inspect}"
          arr
           
  end

  def send_posted_question_notification_to_chosen_phones audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
    if(!audien_details.blank? && audien_details.has_key?("phone_numbers") && !audien_details["phone_numbers"].nil?)
      audien_details["phone_numbers"].each do |number|
        phone_user = User.find_by_phone_number(number)
        if(phone_user.present? && make_friendship_standard(phone_user.reecher_id, user.reecher_id) )
          if linked_quest_type == "ASK"
            PostQuestionToFriend.create(:user_id =>user.reecher_id ,:friend_reecher_id =>phone_user.reecher_id, :question_id=>question.question_id)
          elsif(linked_quest_type == "LINKED" && !phone_user.linked_with_question?(question.id, user.reecher_id))
            LinkedQuestion.create(user_id: phone_user.reecher_id, question_id: question.id, linked_by_uid: user.reecher_id, email_id: phone_user.email, phone_no: phone_user.phone_number, linked_type: linked_quest_type)
            if phone_user.has_email_notifications_enabled?("LINKED")
              UserMailer.email_linked_to_question(phone_user.email, user, question).deliver  unless phone_user.email.blank?
            end
          end
          device_details = Device.find_by_reecher_id(phone_user.reecher_id)
          unless device_details.blank?
            if question != 0
              notify_string = "#{user.full_name}" + push_title_msg
              #notify_string = "#{push_contant_str}," + "<" + user.full_name + ">" + ","+ question.question_id + "," + Time.now().to_s 
            elsif question == 0
              notify_string = push_title_msg
              #notify_string = "#{push_contant_str}," + "<"+  user.full_name + ">" + "," + Time.now().to_s
            end
            if linked_quest_type != "LINKED"
              send_device_notification(device_details[:device_token].to_s, notify_string ,device_details[:platform].to_s,user.full_name+push_title_msg) if phone_user.has_device_notifications_enabled?(linked_quest_type)
              begin
                client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])                                                               
                sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: filter_phone_number(phone_user.phone_number),
                      body: "Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. "
                )
                logger.debug ">>>>>>>>>Sending sms to #{phone_number} with text #{sms.body}"
              rescue Exception => e
                logger.error e.to_s
              end
            end
          end
        elsif !phone_user.present?
          if linked_quest_type !="INVITE"
            get_referal_code_and_token = linked_question_with_type user.reecher_id, question.question_id, '', number, linked_quest_type
            refral_code = get_referal_code_and_token[0][:referral_code]
          elsif linked_quest_type == "INVITE"
            get_referal_code_and_token = linked_question_with_type user.reecher_id , 0, '' , number , linked_quest_type
            refral_code = get_referal_code_and_token[0][:referral_code]
          end
          begin       
            client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])    
                      sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: number,
                      body:"Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. Visit http://reechout.co to download the app and help them out. Invite code: #{refral_code}"
                     )
            logger.debug ">>>>>>>>>Sending sms to #{number} with text"     
          rescue Exception => e
            logger.error e.to_s
          end
        end
      end
    end
  end
       
  def send_posted_question_notification_to_chosen_emails audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
    if(!audien_details.blank? && audien_details.has_key?("emails") && !audien_details["emails"].nil?)
      audien_details["emails"].each do |email|
        email_user = User.find_by_email(email)
        if(email_user.present? && make_friendship_standard(email_user.reecher_id, user.reecher_id) )
          if linked_quest_type == "ASK"
            PostQuestionToFriend.create(:user_id =>user.reecher_id ,:friend_reecher_id =>email_user.reecher_id, :question_id=>question.question_id)
          elsif(linked_quest_type == "LINKED" && !email_user.linked_with_question?(question.id, user.reecher_id))
            LinkedQuestion.create(user_id: email_user.reecher_id, question_id: question.id, linked_by_uid: user.reecher_id, email_id: email_user.email, phone_no: email_user.phone_number, linked_type: linked_quest_type)
            if email_user.has_email_notifications_enabled("LINKED")
              UserMailer.email_linked_to_question(email_user.email, user, question).deliver  unless email_user.email.blank?
            end
          end
          device_details = Device.find_by_reecher_id(email_user.reecher_id)
          unless device_details.blank?
            if question != 0
              notify_string = "#{user.full_name}" + push_title_msg
              #notify_string = "#{push_contant_str}," + "<" + user.full_name + ">" + ","+ question.question_id + "," + Time.now().to_s 
            elsif question == 0
              notify_string = push_title_msg
              #notify_string = "#{push_contant_str}," + "<"+  user.full_name + ">" + "," + Time.now().to_s
            end
            if linked_quest_type != "LINKED"
              send_device_notification(device_details[:device_token].to_s, notify_string ,device_details[:platform].to_s,user.full_name+push_title_msg) if email_user.has_device_notifications_enabled?(linked_quest_type)
              if email_user.phone_number != nil
                begin
                  client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])                                                               
                  sms = client.account.sms.messages.create(
                        from: TWILIO_CONFIG['from'],
                        to: filter_phone_number(email_user.phone_number),
                        body: "Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. "
                  )
                    logger.debug ">>>>>>>>>Sending sms to #{phone_number} with text #{sms.body}"
                  rescue Exception => e
                   logger.error e.to_s
                end 
              end
            end
          end
        elsif !email_user.present?
          if linked_quest_type !="INVITE"
            get_referal_code_and_token = linked_question_with_type user.reecher_id, question.question_id, email, '', linked_quest_type
            UserInvitationWithQuestionDetails.send_linked_question_details(email, user, get_referal_code_and_token[0][:token], get_referal_code_and_token[0][:referral_code], question.question_id, linked_quest_type).deliver  
          elsif linked_quest_type == "INVITE"
            get_referal_code_and_token = linked_question_with_type user.reecher_id, 0, email, '', linked_quest_type
            UserInvitationWithQuestionDetails.send_linked_question_details(email, user,get_referal_code_and_token[0][:token], get_referal_code_and_token[0][:referral_code], 0, linked_quest_type).deliver
          end
        end
      end
    end
  end
 
  
  def is_question_linked_to_user question_id,user_id,linked_by_uid
    @lk = LinkedQuestion.where("question_id=? AND linked_type=? AND user_id=? AND linked_by_uid=?" , question_id , "LINKED" , user_id , linked_by_uid)
   
    quest_owner = Question.find_by_question_id(question_id) 
    if(quest_owner.posted_by_uid == user_id) 
       flag =true  
    elsif (!@lk.blank?)
       flag =true   
    else
       flag =false                   
    end 
  
    return flag
  end
  
 
 def check_push_notification_setting_ask_link_invite linked_type , reecher_id 
   if linked_type == "LINKED"
    c_setting = notify_linked_to_question reecher_id
   elsif linked_type == "ASK"
      c_setting = notify_audience_if_ask_for_help reecher_id
   elsif linked_type == "INVITE"  
      c_setting =  check_push_notification_enable reecher_id
   end
   c_setting
   
 end
  
 
  
end
