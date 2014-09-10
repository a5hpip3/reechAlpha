json.status 200
json.user_details do   
  json.array! @user_profile
  json.(@user_profile.user_profile, :location, :bio, :picture_file_name, :profile_pic_path, :reecher_interests, :reecher_fav_music, :reecher_fav_movies, :reecher_fav_books, :reecher_fav_sports, :reecher_fav_destinations, :snippet)
  json.image_url @user_profile.user_profile.image_url
  json.curio_points  @user_profile.points
  json.total_questions_asked  @user_profile.questions.size
  json.total_solutions_provided  get_user_total_solution(params[:user_id])
  json.total_connections  @user_profile.friendships.accepted.size
end 
