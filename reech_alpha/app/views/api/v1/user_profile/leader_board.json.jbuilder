json.status 200
json.message "Success"
json.leader_detail do
	['today', 'week', 'month'].each do |type|
      json.set! type do
   	   json.user_position User.where(id: current_user.id) do |user|
   		   json.reecherid user.reecher_id
   			json.position user[type+'_position']
   			json.reechername user.full_name
   			json.reecherimage user.image_url
   			json.level 7
   			json.scores user.scores[type]   	   		  
   	   end
   	   json.top_positions do
   		   json.array! User.where(id: current_user.friends.pluck(:id) << current_user.id).order("#{type}_position DESC").limit(5) do |user|
	   		   json.reecherid user.reecher_id
	   		   json.position user[type+'_position']
	   		   json.reechername user.full_name
	   		   json.reecherimage user.image_url
	   		   json.level 7
	   		   json.scores user.scores[type]
   	     end
   	  end
	   end
   end	
end
