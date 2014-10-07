json.array! current_user.friends do |friend|
	json.(friend, :id, :reecher_id, :first_name, :last_name, :phone_number, :email)
	json.groups friend.groups.where(id: current_user.owned_groups)
end
