class Category < ActiveRecord::Base
	attr_accessible :title
	has_many :questions
	has_many :solutions, through: :questions
	def self.get_category_list user_id
		user= User.find_by_reecher_id(user_id)
		@categories = Category.select("id,title").all unless user.blank?  
	end

	def question_count
		self.questions.count
	end

	def solution_count
		self.solutions.count
	end
end
