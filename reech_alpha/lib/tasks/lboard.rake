namespace :lboard do
  desc "Calculate leaderboard for existing data."
  task :init => :environment do
    User.all.each do |user|
      question_count = user.questions.count
      answer_count = user.answered_solutions.count
      hi5_count = user.user_profile.votes_for.count
      curios = user.points
      position = ((0.15 * curios) + (0.2* question_count) + (0.3*answer_count) + (0.35*hi5_count))
      puts user.id.to_s + " - " + position.to_s
    end
  end

  desc "Calculate leaderboard from previous run."
  task :calculate => :environment do
  end

end
