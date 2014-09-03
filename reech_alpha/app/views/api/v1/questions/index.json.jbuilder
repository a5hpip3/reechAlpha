json.status 200
json.questions @questions do |q|
	pqtfs = PostQuestionToFriend.where("question_id = ?", q.question_id).pluck(:friend_reecher_id)
	
	json.(q, :id, :post, :posted_by, :posted_by_uid, :created_at, :updated_at, :ups, :downs, :question_id, :sash_id, :level, :Charisma, :is_public, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :audien_user_ids, :category_id)

	if action_name == "index"

		owner_purchased_solutions = PurchasedSolution.where(user_id: q.user, :solution_id => Solution.where(solver_id: current_user, question_id: q)).pluck(:solution_id)

		if(!owner_purchased_solutions.blank? || (( current_user ==  q.posted_by_uid) || q.is_public))
			json.question_referee q.user.full_name
			json.no_profile_pic false
		elsif(!pqtfs.blank? && (pqtfs.include? current_user))
			json.question_referee q.user.full_name
			json.no_profile_pic false
		else
			json.question_referee = "Friend"
	        json.no_profile_pic = true
		end

	end

	owner_purchased_solutions = PurchasedSolution.where(user_id: q.user.id, :solution_id => Solution.where(question_id: q)).pluck(:user_id)

	if !owner_purchased_solutions.blank?
		json.has_solution = true
	else
		json.has_solution = false
	end

	q.is_stared? ? (json.stared true) : (json.stared false)
	q.avatar_file_name != nil ? (json.image_url q.avatar_url) : (json.image_url nil)
	if !q.avatar_file_name.blank?
		#avatar_geo=((q.avatar_geometry).to_s).split('x') 	
		#json.image_width avatar_geo[0]
		#json.image_height avatar_geo[1] 	
	end

	json.owner_location q.user.user_profile.location
	q.user.user_profile.picture_file_name != nil ? (json.owner_image q.user.user_profile.thumb_picture_url) : (json.owner_image nil)
end