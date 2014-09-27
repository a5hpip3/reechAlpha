json.array! current_user.owned_groups do |group|
	json.id group.id
	json.name group.name
	json.members group.members
end
