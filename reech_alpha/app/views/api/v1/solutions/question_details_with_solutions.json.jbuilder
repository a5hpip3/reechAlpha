json.status 200
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
json.qust_details question
json.solutions result.sort_by{|r| r[:purchased] ? 1 : 0}
json.is_login_user_starred_qst Voting.where(user_id: current_user.id, question_id: question.id).exists?
