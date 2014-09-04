namespace :lboard do
  desc "Calculate leaderboard for existing data."
  task :init => :environment do
    first_date = User.first.created_at.to_date #This is the application start. Run this only once.
    (first_date..(Time.now.to_date)).to_a.each do |day|
      User.all.each do |user|
        lboard = user.leader_boards.new(current_date: day)
        lboard.question_count = user.questions.where(:created_at => day.beginning_of_day..day.end_of_day).count
        lboard.answer_count = user.answered_solutions.where(:created_at => day.beginning_of_day..day.end_of_day).count
        lboard.hi5_count = user.user_profile.votes_for.where(:created_at => day.beginning_of_day..day.end_of_day).count
        lboard.curios = user.score_points.where(:created_at => day.beginning_of_day..day.end_of_day).sum(:num_points)
        lboard.position = ((0.15 * lboard.curios.to_f) + (0.2* lboard.question_count) + (0.3*lboard.answer_count) + (0.35*lboard.hi5_count))
        lboard.save
      end
    end
  end

  desc "Calculate leaderboard from previous run."
  task :calculate => :environment do
  end

end
