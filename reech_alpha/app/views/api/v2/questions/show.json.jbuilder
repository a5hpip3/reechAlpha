question = Question.find(params[:id])

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


solutions = question.solutions
current_user_is_audien = question.post_question_to_friends.pluck(:friend_reecher_id).include?(current_user.reecher_id)
purchased_solutions = question.solutions.where(id: question.purchased_solutions.where(user_id: current_user.id).collect(&:solution_id))
solutions_by_audience = question.solutions.where(solver_id: question.post_question_to_friends.collect(&:friend_reecher_id)) - purchased_solutions
solutions_by_friends = question.solutions.where(solver_id: (current_user.friends.collect(&:reecher_id) - solutions_by_audience.collect(&:solver_id) - purchased_solutions.collect(&:solver_id)))
own_solutions = solutions.where(solver_id: current_user.reecher_id)
solutions_by_others = solutions - solutions_by_friends - solutions_by_audience - purchased_solutions - own_solutions

all_solutions = {purchased_solutions: purchased_solutions, own_solutions: own_solutions, solutions_by_audience: solutions_by_audience, solutions_by_friends: solutions_by_friends, solutions_by_others: solutions_by_others}
json.solutions do
  json.array! all_solutions.values.reduce(:+) do |actual_solution|
    all_solutions.each do |solution_type, current_solutions|
  	  current_solutions.each do |solution|
        if actual_solution.id == solution.id
      		json.id solution.id
        	json.solver solution.solver
        	json.solver_id solution.wrote_by.id    
        	json.image_url  solution.picture_file_name != nil ? solution.picture_url : nil
        	json.previewed  solution.preview_solutions.exists?(user_id: current_user.id) 
        	json.profile_pic_clickable true
          json.purchased   false
        	json.body solution.body
        	json.hi5_count solution.count_votes_up
        	json.current_user_is_solver current_user.reecher_id == solution.solver_id
          if solution_type.to_s == "purchased_solutions"   
            json.purchased   true
          end
          if solution_type.to_s == "solutions_by_audience"
            if solution.solver_id != current_user.reecher_id            
              if  Friendship::are_friends(current_user.reecher_id, solution.solver_id) 
                if !current_user_is_audien && (current_user.reecher_id != question.posted_by_uid)
                  json.solver "Friend"
                  json.image_url nil
                  json.profile_pic_clickable false
                end
              end
            end
          end
          if solution_type.to_s == "solutions_by_friends"
            json.solver "Friend"
            json.image_url nil
            json.profile_pic_clickable false
          end
          if solution_type.to_s == "solutions_by_others"          
            linker = question.linked_questions.where(user_id: solution.solver_id).first
            linker = linker.linked_by unless linker.nil?
            linker = ([linker] + (current_user.friends & solution.wrote_by.friends))[0]
            if current_user.reecher_id == question.posted_by_uid
              json.solver_id linker.id  
              json.solver "Friend of #{linker.full_name}"
              json.image_url linker.image_url
              json.profile_pic_clickable true
            else
              json.solver "Friend of Friend"
              json.image_url nil
              json.profile_pic_clickable false
            end
          end
        end
  	  end
    end
  end
end