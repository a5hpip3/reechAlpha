json.questions_count @user.questions.count 
json.answered_solutions_count @user.answered_solutions.count
json.image_url @user.image_url
json.social_user @user.authorizations.empty? ? false : true
json.curio_points  @user.points
json.high_fives @user.user_profile.votes_for.count
json.location @user.user_profile.location
json.full_name @user.full_name
json.connections_count @user.friends.count
json.phone_number @user.phone_number
json.id @user.id
json.profile_id @user.user_profile.id