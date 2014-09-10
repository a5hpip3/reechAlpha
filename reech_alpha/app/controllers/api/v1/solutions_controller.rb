module Api
	module V1
		class SolutionsController < ApiController
		before_filter :restrict_access
    before_filter :set_params, only: :create
    
		respond_to :json

    require 'pp'
    require 'stringio'
    def set_params      
      params[:solution] = {body: params[:solution], solver_id: current_user.reecher_id, solver: current_user.full_name, question_id: params[:question_id], is_public: params[:is_public]}
      params[:solution][:picture] = StringIO.new(Base64.decode64(params[:solution_image]))  unless params[:solution_image].blank?           
      params[:solution][:picture] = params[:file] unless params[:file].blank? 
    end
  
		


			def purchase_solution
			  user = User.find_by_reecher_id(params[:user_id])
				solution = Solution.find(params[:solution_id])
				question = Question.where(:question_id =>solution.question_id)
				question_id = question[0][:question_id]
				quest_asker = question[0][:posted_by_uid]
        quest_is_public = question[0][:is_public]

				purchased_sl = PurchasedSolution.where(:user_id => user.id, :solution_id => solution.id)
				if purchased_sl.present?
					msg = {:status => 400, :message => "You have Already Purchased this Solution."}
				else
					if user.points > solution.ask_charisma
						purchased_solution = PurchasedSolution.new
						purchased_solution.user_id = user.id
						purchased_solution.solution_id = solution.id
						purchased_solution.save
						if ((quest_asker.to_s == user.reecher_id.to_s) && !quest_is_public)
						 PostQuestionToFriend.create(:user_id =>user.reecher_id ,:friend_reecher_id =>solution.solver_id, :question_id=>question[0][:question_id])
						end
						#Make friend between login user and solution provider
						check_friend = Friendship::are_friends(user.reecher_id,solution.solver_id)

				   # linked_by = LinkedQuestion.find_by_question_id(solution.question_id)
  					linked_by = LinkedQuestion.where("question_id=? AND linked_type=?", solution.question_id,"LINKED")
            linked_by=linked_by[0]  if !linked_by.blank?
            solver_details = User.find_by_reecher_id(solution.solver_id)
				    linker_user = User.find_by_reecher_id(linked_by.linked_by_uid)  if !linked_by.blank?
				    msgText = "<"+user.full_name+">"

  							if (!linked_by.blank?) && ((solver_details.reecher_id).to_s == (linked_by.user_id).to_s)
                 notify_string ="GRABLINK1," + msgText + "," + (solution.id).to_s + "," + Time.now().to_s
                else
                 if check_friend
                 notify_string ="GRABSOLS," + msgText + "," + (solution.id).to_s + "," + Time.now().to_s
                 else
                 notify_string ="GRABLINK2," + msgText + "," + (solution.id).to_s + "," + Time.now().to_s
                 end

                end



         	  if !check_friend
         	  make_friendship_standard(user.reecher_id,solution.solver_id)
						end
						#End of friendship  code
						# Send notification to the solver
						check_setting= notify_when_someone_grab_my_answer(solution.solver_id)
						if check_setting
						  solver_details = User.find_by_reecher_id(solution.solver_id)
						  if !solver_details.blank?
                 device_details = Device.where(:reecher_id=>solver_details.reecher_id)
                 if !device_details.blank?
                   #notify_string ="GRABSOLS," + user.full_name + "," + (solution.id).to_s + "," + Time.now().to_s
                   device_details.each do |d|
                    # puts "SEND NOTIFICATION TO SOLUTION PROVIDER ==#{notify_string}"
                        send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.first_name+PUSH_TITLE_GRABSOLS)
                   end

                 end
              end
            end

           #Send email notification when some grabmy solution
          check_email_setting = check_email_when_someone_grab_my_answer(solution.solver_id)
          if check_email_setting
           @solver = User.find_by_reecher_id(solution.solver_id)
           UserMailer.email_when_someone_grab_my_answer(@solver.email,user,@solution).deliver  unless @solver.email.blank?
          end
						preview_solution = PreviewSolution.find_by_user_id_and_solution_id(user.id, solution.id)
						preview_solution.destroy
						#Add points to solution provider
						solution_provider = User.find_by_reecher_id(solution.solver_id)
						#Revert back the points to user who post the question

					   	if linked_by.blank?
						    quest_asker = question[0][:posted_by_uid]
						    solution_provider.add_points(solution.ask_charisma)
						    if quest_asker == params[:user_id]
							   user.subtract_points(solution.ask_charisma)
							   all_solution_for_this_question = Solution.where(:question_id=>solution.question_id)
							   all_solution_for_this_question = all_solution_for_this_question.collect{|s| s.id}
							   ssss =check_one_time_bonus_distribution(solution.question_id ,all_solution_for_this_question,user.id)
							   if ssss
							     user.add_points(10)
							   end
						    else
						     user.subtract_points(solution.ask_charisma)
						    end

					    else
					    	one_by_five = (((solution.ask_charisma).to_i ) * 2/5).floor
					    	fourth_by_five = (((solution.ask_charisma).to_i ) * 3/5).floor
					    	linker_user.add_points(one_by_five)
					    	solution_provider.add_points(fourth_by_five)
                all_solution_for_this_question = Solution.where(:question_id=>solution.question_id)
                all_solution_for_this_question = all_solution_for_this_question.collect{|s| s.id}
					    	quest_asker = question[0][:posted_by_uid]
					    	if quest_asker== params[:user_id]
							   user.subtract_points(solution.ask_charisma)
							   ssss =check_one_time_bonus_distribution(solution.question_id ,all_solution_for_this_question,user.id)
                 if ssss
                   user.add_points(10)
                 end
						    else
						     user.subtract_points(solution.ask_charisma)
						    end
					    end
             # make friend


						msg = {:status => 200, :message => "Success"}
					else
						msg = {:status => 400, :message => "Sorry, you need at least #{solution.ask_charisma} Charisma Credits to purchase this Solution! Earn some by providing Solutions!"}
					end
				end
				render :json => msg
			end

			def view_solution
				solution = Solution.find(params[:solution_id])
				solution_owner_profile = solution.wrote_by.user_profile
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] =  solution.picture_original_url : @solution[:image_url] = nil
				solution_owner_profile.picture_file_name != nil ? @solution[:solver_image] = solution_owner_profile.picture_url : @solution[:solver_image] = nil
			    user = current_user
			    res  =  ActiveRecord::Base.connection.select("Select count(*) as num_row from votes where voter_id=#{user.id} and votable_id=#{solution.id} and votable_type ='Solution';")
			    res_num_row =res[0]
			    if res_num_row["num_row"] >0
			     hi5 =true
			     else
			     hi5 =false
			    end
		    msg = {:status => 201, :message => "Success", :user_id=>solution_owner_profile.reecher_id}
				msg = {:status => 200, :solution => @solution ,:has_hi5=>hi5}
				render :json => msg
			end
			def preview_solution
				@user = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.find(params[:solution_id])
				@preview_solution = PreviewSolution.where(:user_id => @user.id, :solution_id => @solution.id)
				if @preview_solution.present?
				  msg = {:status => 400, :message => "You have to purchase this solution."}
				else
					preview_solution = PreviewSolution.new
					preview_solution.user_id = @user.id
					preview_solution.solution_id = @solution.id
					preview_solution.save
					msg = {:status => 200, :solution => @solution}
				end
				render :json => msg
			end

			def previewed_solutions
				@user = User.find_by_reecher_id(params[:user_id])
				previewed_solutions = @user.preview_solutions
				solution_ids = []
				if previewed_solutions.size > 0
					previewed_solutions.each do |ps|
						solution_ids << ps.solution_id
					end
				end
				msg = {:status => 200, :solution_ids => solution_ids}
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{solution_ids}"
				render :json => msg
			end

			def solution_hi5
				solution = Solution.find(params[:solution_id])
				user = User.find_by_reecher_id(params[:user_id])
				solution.liked_by(user)
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] =  solution.picture_url : @solution[:image_url] = nil
				# send push notification while hi5 solution
				check_setting = notify_solution_got_highfive(solution.solver_id)
               if check_setting
                device_details=Device.select("device_token,platform").where("reecher_id=?",solution.solver_id.to_s)
                response_string ="HGHFV,"+ "<" +user.full_name + ">"+ "," + params[:solution_id] +","+Time.now().to_s
                if !device_details.empty?
                    device_details.each do |d|
                      send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s,user.full_name+PUSH_TITLE_HGHFV)
                    end
                end
               end

        # Send email notification solution provider if any one hi5
         check_email_setting = check_email_solution_got_highfive(solution.solver_id)
         if check_email_setting
           @solver = User.find_by_reecher_id(solution.solver_id)
           UserMailer.email_solution_got_highfive(@solver.email,user,@solution[:body]).deliver unless @solver.email.blank?
         end

				solution.picture_file_name != nil ? @solution[:image_url] =solution.picture_url : @solution[:image_url] = nil
				msg = {:status => 200, :solution => @solution}

				render :json => msg


			end

       def get_solution_details
        sol_id = params[:solution_id]
        sol_details = Solution.find_by_question_id(sol_id)
        msg = {:status => 200, :solution_details => sol_details}
        render :json =>msg

       end


      def question_details_with_solutions        
        qust_details = Question.find_by_question_id(params[:question_id])
        question_owner = qust_details.user
        logined_user = current_user
        if logined_user.reecher_id == question_owner.reecher_id
         solutions = qust_details.solutions 
        else
          solutions =  Solution.where("question_id=? AND (solver_id=? OR is_public =?)", params[:question_id],params[:user_id],true)
        end

        question_owner_profile = question_owner.user_profile
        qust_details.is_stared? ? qust_details[:stared] = true : qust_details[:stared] =false
        qust_details[:owner_location] = question_owner_profile.location
        qust_details[:avatar_file_name] != nil ? qust_details[:image_url] =  qust_details.avatar_original_url : qust_details[:image_url] = nil
        qust_details[:question_referee] = question_owner.full_name
        qust_details[:question_referee_id] = question_owner.reecher_id
        question_owner_profile.picture_file_name != nil ? qust_details[:owner_image] = question_owner_profile.thumb_picture_url : qust_details[:owner_image] = nil

        voting = Voting.where(:user_id=> logined_user.id, :question_id=> qust_details.id)

          if voting.blank?
           is_login_user_starred_qst = false
          else
           is_login_user_starred_qst = true
          end

        @solutions = []
        @lk_user =  LinkedQuestion.where("question_id=? AND linked_type=?",params[:question_id],"LINKED").pluck(:user_id)
        check_login_user_in_lk_user = @lk_user.include? logined_user.reecher_id if !@lk_user.blank?

        if ((!@lk_user.blank?) && check_login_user_in_lk_user)
         @lk = LinkedQuestion.where("question_id=? AND linked_type=? AND user_id=?", params[:question_id],"LINKED",logined_user.reecher_id)
         @lk=@lk[0]
        else
          @lk = LinkedQuestion.where("question_id=? AND linked_type=?",params[:question_id],"LINKED")
          @lk=@lk[0]
        end
        reecher_user_associated_to_question = qust_details.post_question_to_friends.pluck(:friend_reecher_id)
        question_asker = qust_details.posted_by_uid
        question_user = qust_details.user
        question_asker_name = question_user.full_name
        question_is_public = qust_details.is_public
        question_linker_reecher_id = @lk.linked_by_uid  unless @lk.blank?
        linked_user_to_question = @lk.user_id  unless @lk.blank?
        question_linker_details= @lk.linked_by unless @lk.blank?
        check_friend_with_login_user_and_question_owner = Friendship::are_friends(linked_user_to_question, question_owner.reecher_id)

        if ((!@lk.blank? && (logined_user.reecher_id == linked_user_to_question) && check_friend_with_login_user_and_question_owner) || (reecher_user_associated_to_question.include? logined_user.reecher_id.to_s || ((logined_user.reecher_id ==  question_asker) || question_is_public)))
          qust_details[:question_referee] = question_owner.full_name
          qust_details[:no_profile_pic] = false
        elsif (!@lk.blank? && (logined_user.reecher_id == linked_user_to_question))
          qust_details[:question_referee] = "Friend of "+question_linker_details.full_name
          qust_details[:question_referee_id] = question_linker_details.reecher_id
          qust_details[:no_profile_pic] = false
          question_linker_details.user_profile.picture_file_name != nil ? qust_details[:owner_image] = question_linker_details.user_profile.thumb_picture_url : qust_details[:owner_image] = nil
        else
          qust_details[:question_referee] = "Friend"
          qust_details[:no_profile_pic] = true
        end

        if solutions.size > 0
          solutions.each do |sl|
            solution_attrs = sl.attributes
            user = sl.wrote_by
            user.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = user.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
            sl.picture_file_name != nil ? solution_attrs[:image_url] = sl.picture_url : solution_attrs[:image_url] = nil
            ############
            check_friend_with_login_and_solver = Friendship::are_friends(logined_user.reecher_id,sl.solver_id)

            purchased_sl = PurchasedSolution.where(:user_id => logined_user.id, :solution_id => sl.id)

            if purchased_sl.present?
              solution_attrs[:purchased] = true
            else
              solution_attrs[:purchased] = false
            end

            if !sl.picture_file_name.blank?
           	sol_pic_geo=((sl.sol_pic_geometry).to_s).split('x')
  	        solution_attrs[:image_width]=sol_pic_geo[0]
  	        solution_attrs[:image_height] = sol_pic_geo[1]
            end
            if purchased_sl.present?
                    solution_attrs[:solution_provider_name] = user.full_name
                    solution_attrs[:no_profile_pic] = false
                    solution_attrs[:profile_pic_clickable] = true
             elsif(sl.solver_id == logined_user.reecher_id)
                   solution_attrs[:solution_provider_name] = user.full_name
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = true
             elsif(question_asker.to_s == (logined_user.reecher_id).to_s && @lk.blank?)
                 if ((question_is_public == true) || ((!reecher_user_associated_to_question.blank?) && (reecher_user_associated_to_question.include? sl.solver_id)) )
                   solution_attrs[:solution_provider_name] = user.full_name
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = true
                 else
                   solution_attrs[:solution_provider_name] = "Friend"
                   solution_attrs[:no_profile_pic] = true
                   solution_attrs[:profile_pic_clickable] = false
                 end


             elsif (question_asker==logined_user.reecher_id && !@lk.blank? )


                if (((reecher_user_associated_to_question.include?(question_linker_reecher_id)) || (question_is_public == true) ) && question_linker_reecher_id.to_s == (user.reecher_id).to_s )
                   
                   solution_attrs[:solution_provider_name] = question_linker_details.full_name
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = false
                   question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil

                 elsif ((( !reecher_user_associated_to_question.include?(question_linker_reecher_id)) || (question_is_public == true) ) && question_linker_reecher_id.to_s == (user.reecher_id).to_s )
                   
                   solution_attrs[:solution_provider_name] = "Friend"
                   solution_attrs[:no_profile_pic] = true
                   solution_attrs[:profile_pic_clickable] = false
                   question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
                 elsif ((question_is_public == true) && (sl.solver_id == linked_user_to_question))
                   
                   solution_attrs[:solution_provider_name] = "Friend of #{question_linker_details.first_name}"
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = false
                   question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil

                 elsif ( ( (reecher_user_associated_to_question.include? question_linker_reecher_id ) && (question_linker_reecher_id == question_asker)) || (question_is_public == true))
                   
                   solution_attrs[:solution_provider_name] = user.full_name
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = true
                 elsif ( ((reecher_user_associated_to_question.include? question_linker_reecher_id ) ) || (question_is_public == true))
                   
                   solution_attrs[:solution_provider_name] = "Friend of #{question_linker_details.first_name}"
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = false
                   question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil

                 else
                   
                   solution_attrs[:solution_provider_name] = "Friend of Friend"
                   solution_attrs[:no_profile_pic] = true
                   solution_attrs[:profile_pic_clickable] = false
                 end

            # When logged in person is a linked user
            elsif (logined_user.reecher_id==linked_user_to_question && !@lk.blank? )
              
                 if ((question_linker_reecher_id.to_s == (user.reecher_id).to_s))
                   solution_attrs[:solution_provider_name] = question_linker_details.full_name
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = false
                   question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
                 elsif(check_friend_with_login_and_solver && (question_linker_reecher_id.to_s != (user.reecher_id).to_s) )
                   solution_attrs[:solution_provider_name] = "Friend"
                   solution_attrs[:no_profile_pic] = true
                   solution_attrs[:profile_pic_clickable] = false
                 else
                   solution_attrs[:solution_provider_name] = "Friend of #{question_linker_details.first_name}"
                   solution_attrs[:no_profile_pic] = false
                   solution_attrs[:profile_pic_clickable] = false
                    question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
                 end
            # When logged in person is in choosen audience and solution provider is NOT a linked user
            elsif (((question_is_public == true) || (reecher_user_associated_to_question.include? logined_user.reecher_id)) && @lk.blank? )
            
               if ((( (reecher_user_associated_to_question.include? sl.solver_id)) || question_is_public == true ) && check_friend_with_login_and_solver )
                 #solution_attrs[:solution_provider_name] = sl.solver
                 solution_attrs[:solution_provider_name] = user.full_name
                 solution_attrs[:no_profile_pic] = false
                 solution_attrs[:profile_pic_clickable] = true
               elsif ((( (reecher_user_associated_to_question.include? sl.solver_id)) || question_is_public == true ) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of #{question_owner.first_name}"
                 solution_attrs[:no_profile_pic] = false
                 solution_attrs[:profile_pic_clickable] = false
               elsif ((!reecher_user_associated_to_question.include? sl.solver_id && question_is_public == false) && check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif ((!reecher_user_associated_to_question.include? sl.solver_id && question_is_public == false) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               end
            # When logged in person is in choosen audience and solution provider is a linked user
           elsif (((question_is_public == true) || (reecher_user_associated_to_question.include? logined_user.reecher_id)) && !@lk.blank?)
            
              if ((((reecher_user_associated_to_question.include? question_linker_reecher_id)) || question_is_public == true ) && check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = user.full_name
                 solution_attrs[:no_profile_pic] = false
                 solution_attrs[:profile_pic_clickable] = true
               elsif ((( (reecher_user_associated_to_question.include? question_linker_reecher_id)) || question_is_public == true ) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of #{question_linker_details.first_name}"
                 solution_attrs[:no_profile_pic] = false
                 solution_attrs[:profile_pic_clickable] = false
                  question_linker_details.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = question_linker_details.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
               elsif ((!reecher_user_associated_to_question.include? question_linker_reecher_id && question_is_public == false) && check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif ((!reecher_user_associated_to_question.include? question_linker_reecher_id && question_is_public == false) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               end

            # When logged in person is NOT in choosen audience and solution provider is NOT a linked user
            elsif (((!reecher_user_associated_to_question.blank?) && (!reecher_user_associated_to_question.include? logined_user.reecher_id)) && @lk.blank? )
              puts "When logged in person is NOT in choosen audience and solution provider is NOT a linked user"
               if ((reecher_user_associated_to_question.include? sl.solver_id) && check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif ((reecher_user_associated_to_question.include? sl.solver_id) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif (!(reecher_user_associated_to_question.include? sl.solver_id) && check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif (!(reecher_user_associated_to_question.include? sl.solver_id) && !check_friend_with_login_and_solver )
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               end

           # When logged in person is NOT in choosen audience and solution provider is a linked user
           elsif (((!reecher_user_associated_to_question.blank?) && (!reecher_user_associated_to_question.include? logined_user.reecher_id)) && !@lk.blank?)
              puts "When logged in person is NOT in choosen audience and solution provider is a linked user"
              if((reecher_user_associated_to_question.include? question_linker_reecher_id) && check_friend_with_login_and_solver )
                
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif((reecher_user_associated_to_question.include? question_linker_reecher_id) && !check_friend_with_login_and_solver )
                
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif (!(reecher_user_associated_to_question.include? question_linker_reecher_id) && (logined_user.reecher_id == question_linker_reecher_id))
                
                 #solution_attrs[:solution_provider_name] = sl.solver
                 solution_attrs[:solution_provider_name] = user.full_name
                 solution_attrs[:no_profile_pic] = false
                 solution_attrs[:profile_pic_clickable] = true
               elsif (!(reecher_user_associated_to_question.include? question_linker_reecher_id) && check_friend_with_login_and_solver )
                 
                 solution_attrs[:solution_provider_name] = "Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               elsif (!(reecher_user_associated_to_question.include? question_linker_reecher_id) && !check_friend_with_login_and_solver )
                 
                 solution_attrs[:solution_provider_name] = "Friend of Friend"
                 solution_attrs[:no_profile_pic] = true
                 solution_attrs[:profile_pic_clickable] = false
               end
            else
               #solution_attrs[:solution_provider_name] = sl.solver
               solution_attrs[:solution_provider_name] = user.full_name
               solution_attrs[:no_profile_pic] = false
               solution_attrs[:profile_pic_clickable] = true
            end

            @solutions << solution_attrs

         end

          sorted_sol = []
          @solutions.each do |sol|
            if sol[:purchased]
            sorted_sol << sol
            end
          end
          @solutions.each do |sol|
            if !sol[:purchased]
            sorted_sol << sol
            end
          end

        end
        msg = {:status => 200, :qust_details=>qust_details ,:solutions => sorted_sol,:is_login_user_starred_qst=>is_login_user_starred_qst}
        
        render :json => msg
      end

      


		def check_one_time_bonus_distribution (q_id,sol_id,asker_id)
		 flag =true ;
		  purchased_sl_for_q_id = PurchasedSolution.where(:user_id =>asker_id ,:solution_id=>sol_id)
		  tot_row = purchased_sl_for_q_id.size
		  if tot_row >1
		  flag =false
		  end
		  flag

		end

		def delete_linked_question user_id , question_id
		  @lk = LinkedQuestion.where("user_id = ? and question_id = ? ", user_id , question_id)
      #question_owner = User.find_by_reecher_id(question.posted_by_uid)
      if !@lk.blank?
        @lk.destroy
      end

		end

		end
	end
end			
