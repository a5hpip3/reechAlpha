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
        question = Question.find_by_question_id(params[:question_id])
        question_owner = question.user
        ##############question_details
        question[:stared] = question.is_stared? 
        question[:owner_location] = question_owner.user_profile.location
        question[:avatar_file_name] != nil ? question[:image_url] =  question.avatar_original_url : question[:image_url] = nil
        question[:question_referee] = question_owner.full_name
        question[:question_referee_id] = question_owner.reecher_id
        ###############################                
        solutions = question.solutions
        current_user_is_owner = (current_user.reecher_id == question.posted_by_uid)
        post_question_to_friends = question.post_question_to_friends.pluck(:user_id)
        current_user_is_linked_to_question = question.linked_questions.pluck(:user_id).include? current_user.reecher_id
        link_friends_to_question_owner_current_user = (current_user.friends & question.user.friends).first
        current_user_friend_with_question_owner = Friendship::are_friends(current_user.reecher_id, question.user.reecher_id)    
        
        if (current_user_is_owner ||  current_user_friend_with_question_owner) # || question.is_public
           question[:question_referee] = question_owner.full_name   
           question[:no_profile_pic] = false      
           question.user.user_profile.picture_file_name != nil ? question[:owner_image] = question.user.user_profile.thumb_picture_url : question[:owner_image] = nil
        elsif (current_user_is_linked_to_question || !link_friends_to_question_owner_current_user.nil?)
           link = link_friends_to_question_owner_current_user unless link_friends_to_question_owner_current_user.nil?
           link = question.linked_by if current_user_is_linked_to_question
           question[:question_referee] = "Friend of "+ link.full_name   
           question[:question_referee_id] = link.reecher_id
           question[:no_profile_pic] = false 
           link.user_profile.picture_file_name != nil ? question[:owner_image] = link.user_profile.thumb_picture_url : question[:owner_image] = nil
        else          
           question[:question_referee] = "Friend"  
           question[:no_profile_pic] = true 
           question[:owner_image] = nil
        end 
      	result = []
        solutions.each do |solution|
          solution_attrs = solution.attributes            
          solution.wrote_by.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = solution.wrote_by.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
          solution.picture_file_name != nil ? solution_attrs[:image_url] = solution.picture_url : solution_attrs[:image_url] = nil
          solver_friend_with_current_user = Friendship::are_friends(current_user.reecher_id, solution.solver_id)
          solver_friend_with_question_owner = Friendship::are_friends(question.user.reecher_id, solution.solver_id)
          solution_attrs[:purchased] = PurchasedSolution.where(:user_id => current_user.id, :solution_id => solution.id).exists?
          current_user_is_solver = (current_user.reecher_id == solution.solver_id)            
          if !solution.picture_file_name.blank?
            sol_pic_geo = ((solution.sol_pic_geometry).to_s).split('x')   
            solution_attrs[:image_width] = sol_pic_geo[0] 
            solution_attrs[:image_height] = sol_pic_geo[1]
          end
          solution_attrs[:no_profile_pic] = false
          solution_attrs[:profile_pic_clickable] = true
          

          if solution_attrs[:purchased] || current_user_is_solver
            solution_attrs[:solution_provider_name] = solution.wrote_by.full_name
          else
            if solver_friend_with_question_owner # || question.is_public
              solution_attrs[:solution_provider_name] = solution.wrote_by.full_name
            elsif !(link = question.linked_questions.where(user_id: current_user.reecher_id)).blank? || !(link = (question.user.friends & solution.wrote_by.friends).first).blank?
              link = link.linked_by unless question.linked_questions.where(user_id: current_user.reecher_id).blank?
              solution_attrs[:solution_provider_name] = "Friend of #{link.full_name}" 
              solution_attrs[:solver_image] = nil
              solution_attrs[:solver_image] = link.user_profile.picture_file_name != nil ? link.user_profile.thumb_picture_url : nil 
            else
              solution_attrs[:solution_provider_name] = "Friend"
              solution_attrs[:no_profile_pic] = true
              solution_attrs[:profile_pic_clickable] = false
              solution_attrs[:solver_image] = nil
            end          
          end        
          result << solution_attrs
        end
        msg = {:status => 200, :qust_details=> question ,:solutions => result.sort_by{|r| r[:purchased] ? 1 : 0}, :is_login_user_starred_qst=> Voting.where(user_id: current_user.id, question_id: question.id).exists? }
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
