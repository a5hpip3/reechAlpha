question = Question.find(params[:id])
solutions = question.solutions
question_owner = question.user
current_user_is_owner = (current_user.reecher_id == question.posted_by_uid)
current_user_is_audien = question.post_question_to_friends.pluck(:user_id).include? current_user.reecher_id
current_user_is_linked_to_question = question.linked_questions.pluck(:user_id).include? current_user.reecher_id
current_user_friend_with_question_owner = Friendship::are_friends(current_user.reecher_id, question.user.reecher_id)

##############question_details
json.question do
  #json.extract! question, *question.attributes.keys
  json.id question.id
  json.post question.post
  json.is_stared  question.is_stared?
  json.owner_location  question_owner.user_profile.location
  json.image_url question[:avatar_file_name] != nil ? question.avatar_original_url : nil

  if current_user_is_owner ||  (current_user_friend_with_question_owner  && current_user_is_audien)
    json.question_referee  question_owner.full_name
    json.question_referee_id question_owner.reecher_id
    json.no_profile_pic  false
    json.owner_image  question.user.user_profile.picture_file_name != nil ?  question.user.user_profile.thumb_picture_url : nil
  else
    json.question_referee  "Friend"
    json.question_referee_id nil
    json.no_profile_pic  false
    json.owner_image  "default_reech_pic"
    json.profile_pic_clickable false
  end
end

json.solutions do
  json.array! solutions do |solution|
    #json.extract! solution, *solution.attributes.keys
    current_user_is_solver = (current_user.reecher_id == solution.solver_id)
    solver_friend_with_current_user = Friendship::are_friends(current_user.reecher_id, solution.solver_id)
    solution_is_purchased = current_user.purchased_solutions.exists?(solution_id: solution.id.to_s)
    current_user_linked_solver = !question.linked_questions.where(user_id: solution.solver_id, linked_by_uid: current_user.reecher_id).blank?
    json.id solution.id
    json.image_url  solution.picture_file_name != nil ? solution.picture_url : nil
    json.purchased  solution_is_purchased
    json.no_profile_pic  false
    json.profile_pic_clickable false
    json.body solution.body
    json.hi5_count solution.votes_for.size
    json.current_user_is_solver current_user_is_solver
    json.solution_owner_id solution.wrote_by.id
    json.solution_owner solution.wrote_by.full_name
    json.solution_owner_image solution.wrote_by.user_profile.picture_file_name != nil ? solution.  wrote_by.user_profile.thumb_picture_url : nil    
    json.previewed solution.preview_solutions.exists?(user_id: current_user.id)
    if solution_is_purchased || current_user_is_solver
      json.solution_provider_id solution.wrote_by.id
      json.solution_provider_name solution.wrote_by.full_name
      json.solver_image solution.wrote_by.user_profile.picture_file_name != nil ? solution.wrote_by.user_profile.thumb_picture_url : nil
      json.profile_pic_clickable true
    else
      if solver_friend_with_current_user || current_user_linked_solver
        if current_user_is_owner || current_user_is_audien
          json.solution_provider_id solution.wrote_by.id
          json.solution_provider_name solution.wrote_by.full_name
          json.solver_image solution.wrote_by.user_profile.picture_file_name != nil ? solution.wrote_by.user_profile.thumb_picture_url : nil
          json.profile_pic_clickable true
        else
          json.solution_provider_name "Friend"
          json.solver_image "default_reech_pic"
          json.profile_pic_clickable false
        end
      elsif (link = current_user_is_audien ? current_user.reecher_id : false) || !(link = question.linked_questions.where(user_id: solution.solver_id).pluck(:linked_by_uid)).blank?
        if !(link = (current_user.friends.pluck(:reecher_id) & link).first).blank?
          if current_user_is_audien || question.post_question_to_friends.exists?(user_id: link)
            link = current_user_is_audien ? question_owner : User.find_by_reecher_id(link)
            json.solution_provider_id link.id
            json.solution_provider_name "Friend of #{link.full_name}"
            json.solver_image link.user_profile.picture_file_name != nil ? link.user_profile.thumb_picture_url : nil
            json.profile_pic_clickable true
          else
            json.solution_provider_name "Friend of Friend"
            json.solver_image "default_reech_pic"
            json.profile_pic_clickable false
          end
        end
      else
        json.solution_provider_name "Friend"
        json.solver_image "default_reech_pic"
        json.profile_pic_clickable false
      end
    end
  end
end
json.current_user_starred_question Voting.where(user_id: current_user.id, question_id: question.id).exists?
