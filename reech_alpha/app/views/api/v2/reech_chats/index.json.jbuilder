json.array! @chats do |chat|
	json.(chat, :from_user_id, :to_user_id, :solution_id, :message, :created_at)
	json.status 1
end