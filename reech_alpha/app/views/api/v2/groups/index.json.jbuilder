json.array! current_user.owned_groups do |group|
	json.id group.id
	json.name group.name
	json.members group.members do |member|
		json.id member.id
		json.first_name member.first_name
		json.last_name member.last_name
		json.reecher_id member.reecher_id
	end
end
