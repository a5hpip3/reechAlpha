questions = Question.send(params[:scope], current_user)
questions = questions.where(category_id: params[:category_id]) if !params[:category_id].blank?

json.array! questions do |row|
	posted_by = row.user.full_name
	posted_by_avatar = row.user.user_profile.profile_pic_path
	linked_count = row.linked_questions.find_all_by_linked_by_uid(current_user.id).count
	linked = linked_count > 0 ? true : false
	user_id = row.user.id

	if (current_user != row.user) && !(row.post_question_to_friends.empty?) && !(row.post_question_to_friends.include? (current_user))
		linker = current_user.linked_questions.find_by_question_id(row.question_id)
		if linker
			linked_by = User.find_by_reecher_id(linker.linked_by_uid)
			posted_by = linked_by.full_name
			posted_by_avatar = linked_by.user_profile.profile_pic_path
			linked = true
		else
			posted_by = "Friend"
			posted_by_avatar = nil
		end
	end

	json.id row.id
	json.post row.post
	json.posted_by row.posted_by
	json.avatar_file_name row.avatar_file_name
	json.updated_at json.updated_at
	json.posted_by posted_by
	json.posted_by_user_id user_id
	json.has_solution row.solutions.count > 0 ? true : false
	json.is_linked linked
	json.has_conversation false
	json.is_starred row.votings.find_by_user_id(current_user.id) ? true : false
  json.linked_count linked_count

end
