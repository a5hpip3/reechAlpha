class LeaderboardObserver < ActiveRecord::Observer
	observe :question, :solution, :purchased_solution, :vote

	def after_create(record)
		user = record.user
		today_question_count = user.questions.where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day).count
		today_answer_count = user.answered_solutions.where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day).count
		today_hi5_count = user.user_profile.votes_for.where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day).count
		today_curios = user.score_points.where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day).sum(:num_points)
		week_question_count = user.questions.where("created_at >= ?", Time.zone.now.ago(1.week)).count
		week_answer_count = user.answered_solutions.where("created_at >= ?", Time.zone.now.ago(1.week)).count
		week_hi5_count = user.user_profile.votes_for.where("created_at >= ?", Time.zone.now.ago(1.week)).count
		week_curios = user.score_points.where("created_at >= ?", Time.zone.now.ago(1.week)).sum(:num_points)
		month_question_count = user.questions.where("created_at >= ?", Time.zone.now.ago(1.month)).count
		month_answer_count = user.answered_solutions.where("created_at >= ?", Time.zone.now.ago(1.month)).count
		month_hi5_count = user.user_profile.votes_for.where("created_at >= ?", Time.zone.now.ago(1.month)).count
		month_curios = user.score_points.where("created_at >= ?", Time.zone.now.ago(1.month)).sum(:num_points)
		user.today_position = ((0.15 * today_curios.to_f) + (0.2* today_question_count) + (0.3*today_answer_count) + (0.35*today_hi5_count))
		user.week_position = ((0.15 * week_curios.to_f) + (0.2* week_question_count) + (0.3*week_answer_count) + (0.35*week_hi5_count))
		user.month_position = ((0.15 * month_curios.to_f) + (0.2* month_question_count) + (0.3*month_answer_count) + (0.35*month_hi5_count))
		user.scores = {"today" => {"points_earned" => today_curios, "questions_asked" => today_question_count, "answers_given" => today_answer_count, "high_fives" => today_hi5_count}, "week" => {"points_earned" => week_curios, "questions_asked" => week_question_count, "answers_given" => week_answer_count, "high_fives" => week_hi5_count}, "month" => {"points_earned" => month_curios, "questions_asked" => month_question_count, "answers_given" => month_answer_count, "high_fives" => month_hi5_count}}
		user.save
	end
end
