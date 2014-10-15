class Question < ActiveRecord::Base
  include Scrubber
  has_merit

  attr_accessible :post,:id, :posted_by, :posted_by_uid,:question_id, :points, :Charisma, :avatar, :has_solution, :stared, :image_url, :audien_user_ids, :category_id, :ups, :downs, :is_public, :audien_details
  has_attached_file :avatar, :styles => {:medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png" ,:default_style => :original
  serialize :audien_user_ids, Array
  attr_accessor :audien_details
  #do_not_validate_attachment_file_type :avatar
  validates_attachment :avatar, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:avatar].nil? }
  validate :user_and_charisma_points, on: :create

  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  before_save :create_question_id
  after_create :set_points

  belongs_to :user, :foreign_key => 'posted_by_uid', :primary_key => 'reecher_id'
  has_many :votings, :dependent => :destroy
  has_many :solutions, foreign_key: :question_id, primary_key: :question_id, :dependent => :destroy
  has_many :purchased_solutions, through: :solutions
  has_many :linked_questions, :foreign_key => 'question_id', :primary_key => 'id'

  has_many :posted_solutions,
	:class_name => 'Solution',
	:primary_key=>'question_id',
	:foreign_key => 'question_id',
	:order => "solutions.created_at DESC"

  has_many :post_question_to_friends, primary_key: :question_id
  #default_scope { where(:published_at => Time.now - 1.week) }
  belongs_to :category
  
  scope :find_by_category, ->(arg){ where(category_id: arg)}
  class << self
    def get_questions(type, current_user)
      questions_list = send(type, current_user)
    end

    def get_stared_questions(user_id)
      @stared_questions = []
      stared_question_ids = []
      user = User.find_by_reecher_id(user_id)
      stared_questions = user.votings #Voting.all
      puts "stared_questions=#{stared_questions}"
      if stared_questions.size > 0
        stared_questions.each do |sq|
          stared_question_ids << sq.question_id
        end
        @stared_questions = find(stared_question_ids)
      end
      @stared_questions
    end
  end

  # New scopes

  scope :starred, ->(user) {includes(:votings).where("votings.user_id = #{user.id}").order("questions.created_at DESC")}
  scope :linked, ->(user) {includes(:linked_questions).where("linked_questions.user_id = '#{user.reecher_id}'").order("questions.created_at DESC")}
  scope :created_by, ->(user) {where("posted_by_uid = '#{user.reecher_id}'").order("created_at DESC")}
  scope :posted_to, ->(user) {includes(:post_question_to_friends).where("post_question_to_friends.friend_reecher_id='#{user.reecher_id}'")}
  scope :all_feed, ->(user) do
    #pquestions = user.purchased_questions.collect(&:id)
    friends = user.friends.collect(&:reecher_id)
    includes(:purchased_solutions).includes(:votings).includes(:linked_questions).includes(:post_question_to_friends).
    where("purchased_solutions.user_id = ? OR questions.posted_by_uid = ? OR
    votings.user_id = ? OR
    linked_questions.user_id = ? OR
    post_question_to_friends.friend_reecher_id= ? OR
    (questions.is_public= ? AND questions.posted_by_uid IN (?))",
    user.id, user.reecher_id, user.id, user.reecher_id, user.reecher_id, true, friends).order("questions.created_at DESC")
  end

  scope :mine, ->(user) do
    #pquestions = user.purchased_questions.collect(&:id)
    includes(:purchased_solutions).where("purchased_solutions.user_id = ? OR posted_by_uid = ?
    ", user.id, user.reecher_id)
  end


  ##################################################################

  def create_question_id
    self.question_id=gen_question_id
  end

  def avatar_url
    avatar.url(:medium)
  end

  def avatar_original_url
    avatar.url(:original)
  end

  def is_stared?
    self.votings.size > 0 ? true : false
  end

  def get_geometry(style = :original)
    begin
      Paperclip::Geometry.from_file(pic.path(style)).to_s
    rescue
      nil
    end
  end

  def avatar_geometry(style = :medium)
    @geometry ||= {}
    photo_path = (avatar.options[:storage] == :s3) ? avatar.url(style) : avatar.path(style)
    puts "photo_path== #{photo_path.inspect}"
    @geometry[style] ||= Paperclip::Geometry.from_file(photo_path)
  end

  def show_question_owner_name (current_user_id ,question_id,question_owner)
    owner_name = false
    @pqtf = PostQuestionToFriend.select.where("user_id = ? AND friend_reecher_id=? AND question_id =?", question_owner, current_user_id, question_id)
    if pqtf.blank?
    owner_name
    else
    owner_name = true
    end
    owner_name

  end

  def check_question_refer_to_me user_id , friend_reecher_id, question_id
    @question_owner_name = PostQuestionToFriend.where("user_id = ? AND friend_reecher_id= ? AND question_id = ?", q.posted_by_uid, current_user.reecher_id, q.question_id)

  end

  def set_points
    self.add_points(5)
    self.user.subtract_points(10)
  end

  def user_and_charisma_points
    errors.add(:user_points, "Sorry, you need at least 10 Charisma Credits to ask a Question! Earn some by providing Solutions!") unless (user.points > 10)
  end

end
