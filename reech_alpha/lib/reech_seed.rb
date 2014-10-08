class ReechSeed
	
	class << self
		
		def scenario_1a
			a = User.find_or_create_by_email("user_1a_1@example.com", phone_number: "1199999999", first_name: "user_1a_1", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")
			b = User.find_or_create_by_email("user_1a_2@example.com", phone_number: "1299999999", first_name: "user_1a_2", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")
			x = User.find_or_create_by_email("user_1a_3@example.com", phone_number: "1399999999", first_name: "user_1a_3", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")

			#create question
			q1 = a.questions.create(category_id: Category.find_by_title("Arts & Culture"), post: "question from user_1a_1 for scenario 1")

			#make friendships make_friendship_standard
			make_friendship_standard(b.reecher_id, a.reecher_id)
			make_friendship_standard(x.reecher_id, a.reecher_id)
			make_friendship_standard(x.reecher_id, b.reecher_id)

			#post question
			a.post_question_to_friends.create(friend_reecher_id: b.reecher_id, question_id: q1)
			a.post_question_to_friends.create(friend_reecher_id: x.reecher_id, question_id: q1)

			#create solutions
			Solution.create(solver_id: b.reecher_id, question_id: q1.question_id, body: "Solution from user_1a_2")
		end

		def scenario_1b
			a = User.find_or_create_by_email("user_1b_1@example.com", phone_number: "2199999999", first_name: "user_1b_1", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")
			b = User.find_or_create_by_email("user_1b_2@example.com", phone_number: "2299999999", first_name: "user_1b_2", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")
			x = User.find_or_create_by_email("user_1b_3@example.com", phone_number: "2399999999", first_name: "user_1b_3", last_name: "test", password: "test1234", password_confirmation: "test1234", invite_code: "1111")

			#create question
			q1 = a.questions.create(category_id: Category.find_by_title("Arts & Culture"), post: "question from user_1a_1 for scenario 1")

			#make friendships make_friendship_standard
			make_friendship_standard(b.reecher_id, a.reecher_id)
			make_friendship_standard(x.reecher_id, a.reecher_id)
			
			#post question
			a.post_question_to_friends.create(friend_reecher_id: b.reecher_id, question_id: q1)
			a.post_question_to_friends.create(friend_reecher_id: x.reecher_id, question_id: q1)

			#create solutions
			Solution.create(solver_id: b.reecher_id, question_id: q1.question_id, body: "Solution from user_1b_2")
		end

		def scenario_2a
			
		end


		def make_friendship_standard(friends, user)
		# Proceed only if both the IDs are not same 

			puts "friends====#{friends}"
			puts "user-recher_id====#{user}"
			if friends != user
				are_friends1 = Friendship::are_friends(friends,user)
				are_friends2 = Friendship::are_friends(user,friends)

				if !are_friends1
					friend =  Friendship.new()
					friend.reecher_id = friends
					friend.friend_reecher_id = user
					friend.status = "accepted"
					friend.save
				end
				if !are_friends2
					friend2 =  Friendship.new()
					friend2.reecher_id = user
					friend2.friend_reecher_id = friends
					friend2.status = "accepted"
					friend2.save
				end
				return true
			else
				puts "Error : Cant make friendship between same users." 
				return false
			end
		end


	end


end