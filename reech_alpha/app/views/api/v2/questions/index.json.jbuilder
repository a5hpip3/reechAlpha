json.array! [1] do 
	scope = params[:scope] ? params[:scope] : "all"
	questions = Question.send(params[:scope], current_user) if params[:scope].present?
	questions = questions.find_by_category(params[:category_id]) unless params[:category_id].blank?	
	json.questions questions.page(params[:page]).per_page(3)
	json.count questions.count
end

