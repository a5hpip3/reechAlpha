json.status 200
json.questions @questions do |q|
	question = Question.find_by_question_id(q[0])

	json.(question, :id, :post, :posted_by, :posted_by_uid, :created_at, :updated_at, :ups, :downs, :question_id, :sash_id, :level, :Charisma, :is_public, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :audien_user_ids, :category_id)

	if action_name == "index"
		if((!q[2].blank? && (q[2].split(',').include?(current_user.reecher_id))) || current_user.reecher_id == question.posted_by_uid)
			json.question_referee question.user.full_name
			json.no_profile_pic false
		else
			json.question_referee "Friend"
	        json.no_profile_pic true
		end
	end

	if !q[1] == 0
		json.has_solution true
	else
		json.has_solution false
	end

	q[3]==0 ? (json.stared false) : (json.stared true)
	question.avatar_file_name != nil ? (json.image_url question.avatar_url) : (json.image_url nil)
	if !question.avatar_file_name.blank?
		#avatar_geo=((q.avatar_geometry).to_s).split('x')
		#json.image_width avatar_geo[0]
		#json.image_height avatar_geo[1]
	end

	json.owner_location question.user.user_profile.location
	question.user.user_profile.picture_file_name != nil ? (json.owner_image question.user.user_profile.thumb_picture_url) : (json.owner_image nil)
end
