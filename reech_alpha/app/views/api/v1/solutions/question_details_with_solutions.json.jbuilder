json.status 200
question = Question.find_by_question_id(params[:question_id])
question_owner = question.user
current_user_is_owner = (current_user.reecher_id == question.posted_by_uid)
post_question_to_friends = question.post_question_to_friends.pluck(:user_id)
current_user_is_linked_to_question = question.linked_questions.pluck(:user_id).include? current_user.reecher_id
link_friends_to_question_owner_current_user = (current_user.friends & question.user.friends).first
current_user_friend_with_question_owner = Friendship::are_friends(current_user.reecher_id, question.user.reecher_id)    

##############question_details
json.qust_details do
  json.extract! question, *question.attributes.keys
  json.stared  question.is_stared? 
  json.owner_location  question_owner.user_profile.location
  json.image_url question[:avatar_file_name] != nil ? question.avatar_original_url : nil
      
  if (current_user_is_owner ||  current_user_friend_with_question_owner) # || question.is_public
    json.question_referee  question_owner.full_name
    json.question_referee_id question_owner.reecher_id   
    json.no_profile_pic  false      
    json.owner_image  question.user.user_profile.picture_file_name != nil ?  question.user.user_profile.thumb_picture_url : nil
  elsif (current_user_is_linked_to_question || !link_friends_to_question_owner_current_user.nil?)
    link = link_friends_to_question_owner_current_user unless link_friends_to_question_owner_current_user.nil?
    link = question.linked_by if current_user_is_linked_to_question
    json.question_referee  "Friend of "+ link.full_name   
    json.question_referee_id  link.reecher_id
    json.no_profile_pic  false 
    json.owner_image link.user_profile.picture_file_name != nil ?  link.user_profile.thumb_picture_url :  nil
  else          
    json.question_referee  "Friend"  
    json.question_referee_id nil
    json.no_profile_pic  true 
    json.owner_image  nil
  end 
end
result = []
solutions = question.solutions  
json.solutions do
  json.array! solutions do |solution|    
    json.extract! solution, *solution.attributes.keys
    current_user_is_solver = (current_user.reecher_id == solution.solver_id)
    solver_friend_with_current_user = Friendship::are_friends(current_user.reecher_id, solution.solver_id)
    solver_friend_with_question_owner = Friendship::are_friends(question.user.reecher_id, solution.solver_id)
    solution_is_purchased = PurchasedSolution.where(:user_id => current_user.id, :solution_id => solution.id).exists?  
    json.solver_image  solution.wrote_by.user_profile.picture_file_name != nil ? solution.wrote_by.user_profile.thumb_picture_url : nil
    json.image_url  solution.picture_file_name != nil ? solution.picture_url : nil
    json.purchased  solution_is_purchased            
    if !solution.picture_file_name.blank?
      sol_pic_geo = ((solution.sol_pic_geometry).to_s).split('x')   
      json.image_width  sol_pic_geo[0] 
      json.image_height  sol_pic_geo[1]
    end
    json.no_profile_pic  false
    json.profile_pic_clickable true
    if solution_is_purchased || current_user_is_solver || solver_friend_with_current_user
      json.solution_provider_name solution.wrote_by.full_name
    else
      if (!(link = question.linked_questions.where(user_id: current_user.reecher_id)).blank? || !(link = (current_user.friends & solution.wrote_by.friends).first).blank? || !(link = (current_user.friends & question.user.friends).first).blank?)
        link = link.linked_by unless question.linked_questions.where(user_id: current_user.reecher_id).blank?
        link = question.user if current_user_friend_with_question_owner
        json.solution_provider_name "Friend of #{link.full_name}"       
        json.solver_image link.user_profile.picture_file_name != nil ? link.user_profile.thumb_picture_url : nil 
      else
        json.solution_provider_name  "Friend"
        json.no_profile_pic  true
        json.profile_pic_clickable  false
        json.solver_image  nil
      end          
    end 
  end
end
json.is_login_user_starred_qst Voting.where(user_id: current_user.id, question_id: question.id).exists?
