
class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	acts_as_token_authenticatable
	devise :database_authenticatable, :registerable, :trackable, :omniauthable, :omniauth_providers => [:facebook]
	#       :recoverable, :rememberable  #, :trackable, :validatable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email,:phone_number ,:password, :password_confirmation, :remember_me, :group_ids, :user_profile_attributes
	has_merit
	acts_as_voter
	serialize :scores, Hash

	#include BCrypt
	include Scrubber

	#For OmniAuth
	has_many :authorizations, :dependent => :destroy
	attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :points
	serialize :omniauth_data, JSON
	#Scrubber Fields
	before_create :create_unique_profile_id
	before_create :create_reecher_id
	validates :email, uniqueness: true ,:allow_blank => true, :allow_nil => true
	validates :phone_number, uniqueness: true ,:allow_blank => true, :allow_nil => true
	#Authentications

	# friendships
	has_many :friendships,:primary_key=>"reecher_id",:foreign_key=>'reecher_id'
	has_many :friends,
					 :through => :friendships,
					 :conditions => "status = 'accepted'"

	has_many :requested_friends,
					 :through => :friendships,
					 :source => :friend,
					 :conditions => "status = 'requested'",
					 :order => :created_at

	has_many :pending_friends,
					 :through => :friendships,
					 :source => :friend,
					 :conditions => "status = 'pending'",
					 :order => :created_at

	#Questions
	has_many :questions, :primary_key=>"reecher_id",:foreign_key=>'posted_by_uid'
	has_many :post_question_to_friends

	has_many :notifications, :primary_key => "reecher_id", :foreign_key => "to_user"

	has_many :votings
	has_many :starred_questions, through: :votings

  has_many :purchased_solutions
	has_many :solutions, :through => :purchased_solutions
	has_many :purchased_questions, through: :solutions

	has_many :answered_solutions, class_name: "Solution", primary_key: 'reecher_id', foreign_key: 'solver_id'

	has_many :preview_solutions

	#Linked questions
	has_many :linked_questions, :primary_key=>"reecher_id", :foreign_key=>"user_id"
	has_many :linked_actual_questions, through: :linked_questions

  has_and_belongs_to_many :groups, join_table: "groups_users"
  has_many :owned_groups, class_name: "Group", primary_key: 'reecher_id', foreign_key: 'reecher_id'
	# purchased solutions

  has_many :leader_boards
	#Messages
	has_many :messages, class_name: 'Message', foreign_key: 'user_id'


	#Profile

	has_one :user_profile,:primary_key=>:reecher_id,:foreign_key=>:reecher_id, :dependent => :destroy
	accepts_nested_attributes_for :user_profile

	delegate :reecher_interests, :reecher_hobbies, :reecher_fav_music, :reecher_fav_movies,

					 :reecher_fav_books, :reecher_fav_sports, :reecher_fav_destinations,
					 :reecher_fav_cuisines, :bio, :snippet,:reecher_interests=, :reecher_hobbies=, :reecher_fav_music=,
					 :reecher_fav_movies=,:reecher_fav_books=, :reecher_fav_sports=, :reecher_fav_destinations=,
					 :reecher_fav_cuisines=, :bio=, :snippet=,
					 :to => :user_profile

	has_one :user_settings, :primary_key=>:reecher_id,:foreign_key=>:reecher_id, :dependent => :destroy
  accepts_nested_attributes_for :user_settings



	# Devices association for push notifications
	has_many :devices, :primary_key=>"reecher_id", :foreign_key=>"reecher_id"

	# Alias Profile of a reecher to be called User Profile or Reecher Profile
	alias_attribute :reecher_profile,:user_profile

	accepts_nested_attributes_for :user_profile

	before_create :create_reecher_profile
	after_create :assign_points


	def self.create_from_omniauth_data(omniauth_data)
		user = User.new(
			:first_name => omniauth_data['info']['name'].to_s.downcase,
			:email => omniauth_data['info']['email'].to_s.downcase #if present
			)
		user.omniauth_data = omniauth_data.to_json #shove OmniAuth::AuthHash as json data to be parsed later!
		user.save(:validate => false) #create without validations because most of the fields are not set.
		user.reset_persistence_token! #set persistence_token else sessions will not be created
		user
	end

  def all_groups
  	owned_groups + groups
  end

  def name
  	full_name
  end

  def image_url
  	user_profile.image_url
  end
  def reecherId
  	reecher_id
  end
	def create_reecher_id
		self.reecher_id=gen_reecher_id
	end

	def create_unique_profile_id
		self.profile_id=gen_profile_id
	end

	def full_name
		return "#{self.first_name} #{self.last_name}"
	end

	def location
		user_profile.location if user_profile
	end

	def get_friend_associated_groups friend
		#copied from original needs refactoring
		group_ids = Group::get_friend_associated_groups friend ,self.id
		user_group_ids =[]
		group_ids.each do |i|
			user_group_ids.push(i.values)
		end
		user_group_ids.flatten!
	end

	def prefix
		try(:full_name) || email
	end

	def message_title
		"#{prefix} <#{email}>"
	end

	def to_s
		full_name
	end

	def mailbox
		Mailbox.new(self)
	end


	# after_create callback to create new profile associated with the Reecher
	def create_reecher_profile
    self.build_user_profile
		self.build_user_settings
	end

	def assign_points
		self.add_points(500)
	end


	def deliver_password_reset_instructions!
		reset_persistence_token!
		UserMailer.password_reset_instructions(self).deliver
	end

  def picture_from_url(url)
    self.picture = open(url)
  end

  def linked_with_question?(question_id, linked_user)
  	linked_questions.exists?(question_id: question_id, linked_by_uid: linked_user, linked_type: "LINKED")
  end

  def has_device_notifications_enabled?(linked_type)
  	case linked_type
  	when "LINKED"
  		(user_settings.pushnotif_is_enabled && user_settings.notify_linked_to_question)
  	when "ASK"
  		(user_settings.pushnotif_is_enabled && user_settings.notify_audience_if_ask_for_help)
  	when "INVITE"
  		user_settings.pushnotif_is_enabled
  	end
  end

  def has_email_notifications_enabled?(linked_type)
  	case linked_type
  	when "LINKED"
  		(user_settings.emailnotif_is_enabled && user_settings.notify_linked_to_question)
  	when "ASK"
  		(user_settings.emailnotif_is_enabled && user_settings.notify_audience_if_ask_for_help)
  	when "INVITE"
  		user_settings.emailnotif_is_enabled
  	end
  end

	## Omniauth facebook registration
	def self.find_for_facebook_oauth(auth)
    where(email: auth.info.email).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.first_name = auth.info.name   # assuming the user model has a name
    end
  end


end
