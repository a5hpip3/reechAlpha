json.status 200
json.message "Success"
json.leader_detail do
	json.today do
   	json.user_position do
   		json.array! [current_user] do |user|  	
   			json.reecherid user.reecher_id
   			json.position user.today_position
   			json.reechername user.full_name
   			json.reecherimage user.image_url
   			json.level 7
   			json.scores user.scores["today"]   	
   		end
   	end
   	json.top_positions do
   		json.array! current_user.friends.order('today_position DESC').limit(5) do |user|
	   		json.reecherid user.reecher_id
	   		json.position user.today_position
	   		json.reechername user.full_name
	   		json.reecherimage user.image_url
	   		json.level user.level
	   		json.scores user.scores["today"]
   	  end
   	end
	end
	json.week do
		json.user_position do
			json.array! [current_user] do |user| 
   			json.reecherid user.reecher_id
   			json.position user.weekly_position
   			json.reechername user.full_name
   			json.reecherimage user.image_url
   			json.level 7
   			json.scores user.scores["week"]
   		end
   	end
   	json.top_positions do
   		json.array! current_user.friends.order('weekly_position DESC').limit(5) do |user|
	   		json.reecherid user.reecher_id
	   		json.position user.weekly_position
	   		json.reechername user.full_name
	   		json.reecherimage user.image_url
	   		json.level user.level
	   		json.scores user.scores["week"]
	   	end
   	end
 end
	json.month do
		json.user_position do
			json.array! [current_user] do |user| 
   			json.reecherid user.reecher_id
   			json.position user.monthly_position
   			json.reechername user.full_name
   			json.reecherimage user.image_url
   			json.level 7
   			json.scores user.scores["month"]
   		end
   	end
   	json.top_positions do
   		json.array! current_user.friends.order('monthly_position DESC').limit(5) do |user|
	   		json.reecherid user.reecher_id
	   		json.position user.monthly_position
	   		json.reechername user.full_name
	   		json.reecherimage user.image_url
	   		json.level user.level
	   		json.scores user.scores["month"]
	   	end
   	end
  end
end
