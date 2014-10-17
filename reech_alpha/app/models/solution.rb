class Solution < ActiveRecord::Base
	attr_accessible :body, :solver, :solver_id, :down, :up, :ask_charisma, :linked_user, :question_id, :is_public, :picture
	acts_as_votable
	belongs_to :question, foreign_key: :question_id, primary_key: :question_id

	belongs_to :purchased_question, class_name: "::Question", foreign_key: :question_id, primary_key: :question_id

	belongs_to :wrote_by,
	:class_name => 'User',
	:primary_key => 'reecher_id',
	:foreign_key => 'solver_id'

	has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"


	has_many :purchased_solutions
	has_many :users, :through => :purchased_solutions
	has_many :preview_solutions
	has_many :votes, primary_key: :id, foreign_key: :votable_id

	has_many :reech_chats

	has_many :chat_members,
						through: :reech_chats,
						source: :from_user,
						group: :from_user_id,
						conditions: proc {"from_user_id != #{self.wrote_by.id}"}
						

	validates_attachment :picture, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:picture].nil? }
	after_commit :notify_users, on: :create

	def buy(soln)
		solution.ask_charisma = soln
	end

	def self.filter(question, current_user)
		solns = []
		allsolutions = question.posted_solutions
		allsolutions.each do |answer|
			if answer.users.exists?(current_user)
				solns = solns + answer
			end
		end
	end

	def picture_url
		picture.url(:medium)
	end

	def picture_original_url
		picture.url(:original)
	end
	def picture_thumb_url
		picture.url(:thumb)
	end

	def sol_pic_geometry(style = :medium)
		@geometry ||= {}
		photo_path = (picture.options[:storage] == :s3) ? picture.url(style) : picture.path(style)
		@geometry[style] ||= Paperclip::Geometry.from_file(photo_path)
	end

	def notify_users
		NotifyUsersWorker.perform_async(self.id)
	end

end
