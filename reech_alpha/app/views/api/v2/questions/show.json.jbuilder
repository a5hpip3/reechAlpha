question = Question.find(params[:id])
solutions = question.solutions
question_owner = question.user
current_user_is_owner = (current_user.reecher_id == question.posted_by_uid)
current_user_is_audien = question.post_question_to_friends.pluck(:user_id).include? current_user.reecher_id
current_user_is_linked_to_question = question.linked_questions.pluck(:user_id).include? current_user.reecher_id
current_user_friend_with_question_owner = Friendship::are_friends(current_user.reecher_id, question.user.reecher_id)

##############question_details
json.question do 
  posted_by = question.user.full_name
  posted_by_avatar = question.user.user_profile.profile_pic_path
  linked_count = question.linked_questions.find_all_by_linked_by_uid(current_user.reecher_id).count
  linked = linked_count > 0 ? true : false
  user_id = question.user.id
  clickable = true

  if (current_user != question.user) && !(question.post_question_to_friends.empty?) && !(question.post_question_to_friends.collect(&:friend_reecher_id).include? (current_user.reecher_id))
    linker = current_user.linked_questions.find_by_question_id(question.question_id)
    if linker
      linked_by = User.find_by_reecher_id(linker.linked_by_uid)
      posted_by = linked_by.full_name
      posted_by_avatar = linked_by.user_profile.profile_pic_path
      linked = true
      clickable = true
    else
      posted_by = "Friend"
      posted_by_avatar = nil
      clickable = false
    end
  end

  json.id question.id
  json.question_id question.question_id
  json.post question.post
  json.posted_by question.posted_by
  json.avatar_file_name question.avatar_file_name
  json.updated_at json.updated_at
  json.posted_by posted_by
  json.posted_by_user_id user_id
  json.posted_by_avatar posted_by_avatar
  json.has_solution question.solutions.count > 0 ? true : false
  json.is_linked linked
  json.has_conversation false
  json.is_starred question.votings.find_by_user_id(current_user.id) ? true : false
  json.clickable clickable
  json.linked_count linked_count 
end

json.solutions do
  json.array! solutions do |solution|
    current_user_is_solver = (current_user.reecher_id == solution.solver_id)
    solver_friend_with_current_user = Friendship::are_friends(current_user.reecher_id, solution.solver_id)
    solver_friend_with_question_owner = Friendship::are_friends(question_owner.reecher_id, solution.solver_id)
    solver_is_audien = question.post_question_to_friends.pluck(:user_id).include? solution.solver_id
    solution_is_purchased = current_user.purchased_solutions.exists?(solution_id: solution.id.to_s)
    current_user_linked_solver = !question.linked_questions.where(user_id: solution.solver_id, linked_by_uid: current_user.reecher_id).blank?
    json.id solution.id
    json.image_url  solution.picture_file_name != nil ? solution.picture_url : nil
    json.purchased  solution_is_purchased
    json.no_profile_pic  false
    json.profile_pic_clickable false
    json.body solution.body
    json.hi5_count solution.count_votes_up
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
        if (current_user_is_owner && solver_is_audien) || current_user_is_audien
          json.solution_provider_id solution.wrote_by.id
          json.solution_provider_name solution.wrote_by.full_name
          json.solver_image solution.wrote_by.user_profile.picture_file_name != nil ? solution.wrote_by.user_profile.thumb_picture_url : nil
          json.profile_pic_clickable true
        else
          json.solution_provider_name "Friend"
          json.solver_image "default_reech_pic"
          json.profile_pic_clickable false
        end
      elsif current_user_friend_with_question_owner && solver_friend_with_question_owner
        if current_user_is_audien 
          json.solution_provider_id question_owner.id
          json.solution_provider_name "Friend of #{question_owner.full_name}"
          json.solver_image link.user_profile.picture_file_name != nil ? question_owner.user_profile.thumb_picture_url : nil
          json.profile_pic_clickable true
        else
          json.solution_provider_name "Friend of Friend"
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
    if current_user_is_solver
      json.chat_members solution.chat_members do |member|
        json.(member, :id, :first_name, :last_name)
      end
    end
  end
end
json.current_user_starred_question Voting.where(user_id: current_user.id, question_id: question.id).exists?
