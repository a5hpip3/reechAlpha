json.array! @chats do |chat|
	json.(chat, from_user, to_user, solution_id, message, created_at)
	json.status 1
end