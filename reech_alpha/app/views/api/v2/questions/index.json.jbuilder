questions = Question.send(params[:scope], current_user)
questions = questions.where(category_id: params[:category_id]) if !params[:category_id].blank?

json.array! questions do |row|
	posted_by = row.user.full_name
	posted_by_avatar = row.user.image_url
	linked_count = row.linked_questions.find_all_by_linked_by_uid(current_user.reecher_id).count
	linked = linked_count > 0 ? true : false
	user_id = row.user.id
	clickable = true
	can_link = true
	all_links = current_user.linked_questions.find_all_by_question_id(row.id).collect(&:linked_by_uid)
	all_linkers = User.where(reecher_id: all_links).collect(&:full_name)

	if (current_user != row.user) && !(row.post_question_to_friends.empty?) && !(row.post_question_to_friends.collect(&:friend_reecher_id).include? (current_user.reecher_id))
		linker = current_user.linked_questions.find_by_question_id(row.id)
		
		if linker
			unless current_user.friends.include? row.user
				linked_by = User.find_by_reecher_id(linker.linked_by_uid)
				posted_by = "Friend of " + linked_by.full_name
				posted_by_avatar = nil
				linked = true
				can_link = false
				clickable = false
			end
		else
			posted_by = "Friend"
			posted_by_avatar = nil
			clickable = false
		end
	end

	json.id row.id
	json.updated_at row.updated_at
	json.post row.post	
	json.avatar_file_name row.avatar_file_name
	json.updated_at row.updated_at
	json.posted_by posted_by
	json.posted_by_user_id user_id
	json.has_solution row.solutions.count > 0 ? true : false
	json.is_linked linked
	json.has_conversation false
	json.is_starred row.votings.find_by_user_id(current_user.id) ? true : false
	json.clickable clickable
  json.linked_count linked_count
	json.linkers all_linkers
  json.can_link can_link
end
