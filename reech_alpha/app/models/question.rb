class Question < ActiveRecord::Base
  include Scrubber
  has_merit

  attr_accessible :post,:id, :posted_by, :posted_by_uid,:question_id, :points, :Charisma, :avatar, :has_solution, :stared, :image_url, :audien_user_ids, :category_id
  has_attached_file :avatar, :styles => {:medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png" ,:default_style => :original
  serialize :audien_user_ids, Array
  #do_not_validate_attachment_file_type :avatar
  validates_attachment :avatar, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:avatar].nil? }
  validate :user_and_charisma_points, on: :create

  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  before_save :create_question_id
  after_create :set_points

  belongs_to :user, :foreign_key => 'posted_by_uid', :primary_key => 'reecher_id'
  has_many :votings, :dependent => :destroy
  has_many :solutions, :primary_key=>'question_id',:foreign_key => 'question_id',:dependent => :destroy
  has_many :linked_questions, :foreign_key => 'question_id', :primary_key => 'question_id'
  has_many :posted_solutions,
  :class_name => 'Solution',
  :primary_key=>'question_id',
  :foreign_key => 'question_id',
  :order => "solutions.created_at DESC"

  has_many :post_question_to_friends, primary_key: :question_id
  #default_scope { where(:published_at => Time.now - 1.week) }
  belongs_to :category
  # Need to test
  # scope :feed, ->(arg){where("posted_by_uid  IN (?) AND created_at >= ?" , arg.friends.pluck(:friend_reecher_id).push(arg.reecher_id) ,arg.created_at).order("created_at DESC")}

  # scope :stared, ->(arg){where("id in (?)", arg.votings.pluck(:question_id)).order("created_at DESC")}

  # scope :self, ->(arg) do
  #   my_questions = arg.questions.order("created_at DESC").pluck("id")
  #   my_all_questions = (PurchasedSolution.questions(arg) + my_questions).sort
  #   where("id in (?)", my_all_questions).order("created_at DESC")
  # end

  # scope :get_questions, ->(type, current_user) do
  #   questions_list = send(type, current_user)
  #   #filterforuser(current_user.reecher_id, questions_list)
  # end

  ##########################
 #  def create_question_id
 #    self.question_id=gen_question_id
 #  end

 #  # Instead of constructing a JSON array it is better to write a json file usin jbuilder which renders from index action
 # def self.filterforuser user_id , question_list_obj
 #   questions = question_list_obj
 #   @Questions =[]
 #   if !questions.blank?
 #      questions.each do |q|
 #        question_asker = q.posted_by_uid
 #        #puts "question_askerquestion_asker=#{question_asker}"
 #        question_user = User.find_by_reecher_id(question_asker)
 #        #question_asker_name = q.posted_by
 #        question_asker_name = question_user.full_name
 #        question_is_public = q.is_public
 #        @pqtfs = PostQuestionToFriend.where("question_id = ?", q.question_id)
 #        solution_posted_by_login_user = Solution.where( "solver_id = ? AND question_id =? ", user_id , q.question_id)
 #        #puts "!solution_posted_by_login_user=#{question_asker}"
 #        if !solution_posted_by_login_user.empty?
 #          solution_posted_by_login_user_id = solution_posted_by_login_user.collect{|sol| sol.id}
 #        end
 #        purchased_sl_by_question_owner = PurchasedSolution.where(:user_id => question_asker)
 #        if !purchased_sl_by_question_owner.empty?
 #          purchased_sl_by_question_owner = purchased_sl_by_question_owner.collect {|s| s.solution_id}
 #        end
 #        reecher_user_associated_to_question=@pqtfs.collect{|pq| pq.friend_reecher_id} if !@pqtfs.blank?

 #        if ((!purchased_sl_by_question_owner.blank?) && (!solution_posted_by_login_user_id.blank?))
 #          match_ids= solution_posted_by_login_user_id & purchased_sl_by_question_owner
 #          if match_ids.size > 0
 #            #q[:question_referee] = q.posted_by
 #            q[:question_referee] = question_asker_name
 #            q[:no_profile_pic] = false
 #          end
 #        elsif (( user_id ==  question_asker) || question_is_public)
 #          #q[:question_referee] = q.posted_by
 #          q[:question_referee] = question_asker_name
 #          q[:no_profile_pic] = false
 #        elsif(!@pqtfs.blank? && (reecher_user_associated_to_question.include? user_id))
 #          #q[:question_referee] = q.posted_by
 #          q[:question_referee] = question_asker_name
 #          q[:no_profile_pic] = false
 #        else
 #          q[:question_referee] = "Friend"
 #          q[:no_profile_pic] = true
 #        end
 #        @Questions << q
 #      end
 #    else
 #      @Questions = []
 #    end
 # end


 #  def self.get_stared_questions(user_id)
 #    @stared_questions = []
 #    stared_question_ids = []
 #    user = User.find_by_reecher_id(user_id)
 #    stared_questions = user.votings #Voting.all
 #    puts "stared_questions=#{stared_questions}"
 #    if stared_questions.size > 0
 #      stared_questions.each do |sq|
 #        stared_question_ids << sq.question_id
 #      end
 #      @stared_questions = find(stared_question_ids)
 #    end
 #    @stared_questions
 #  end

 class << self
    def feed(arg)
      sql_str = "select q.question_id as q_id, (select count(*) from purchased_solutions WHERE user_id = (select id from users where reecher_id=posted_by_uid) AND solution_id IN (select id from solutions where question_id = q_id)) AS ops, (select CAST(GROUP_CONCAT(friend_reecher_id SEPARATOR ',') AS CHAR) from post_question_to_friends where question_id = q_id) as pqtfs from questions q WHERE (posted_by_uid IN (SELECT friend_reecher_id FROM users INNER JOIN friendships ON users.reecher_id = friendships.friend_reecher_id WHERE friendships.reecher_id = \'#{arg.reecher_id}\' AND (status = 'accepted')) OR posted_by_uid = \'#{arg.reecher_id}\') AND q.created_at >= \'#{arg.created_at}\' ORDER BY q.created_at DESC"
      ActiveRecord::Base.connection.execute(sql_str)
    end

    def stared(arg)
      sql_str = "select q.question_id as q_id, (select count(*) from purchased_solutions WHERE user_id = (select id from users where reecher_id=posted_by_uid)  AND solution_id   IN  (select id from solutions where question_id = q_id)) AS ops, (select CAST(GROUP_CONCAT(friend_reecher_id SEPARATOR ',') AS CHAR) from post_question_to_friends where question_id = q_id) as pqtfs from questions q where q.id IN(select v.question_id from votings v INNER JOIN questions ON v.question_id = questions.id WHERE questions.posted_by_uid = \'#{arg.reecher_id}\') ORDER BY q.created_at DESC"
      ActiveRecord::Base.connection.execute(sql_str)
    end

    def self(arg)
      sql_str = "select q.question_id as q_id, (select count(*) from purchased_solutions WHERE user_id = (select id from users where reecher_id=posted_by_uid)  AND solution_id   IN  (select id from solutions where question_id = q_id)) AS ops, (select CAST(GROUP_CONCAT(friend_reecher_id SEPARATOR ',') AS CHAR) from post_question_to_friends where question_id = q_id) as pqtfs from questions q where q.posted_by_uid = \'#{arg.reecher_id}\' OR q.id IN(select s.question_id from purchased_solutions p INNER JOIN solutions s ON p.solution_id = s.id WHERE p.user_id = #{arg.id}) ORDER BY q.created_at DESC"
      ActiveRecord::Base.connection.execute(sql_str)
    end

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
