class Voting < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :question
  validates_uniqueness_of :user_id, scope: :question_id
  # This is for the user assoc.

  belongs_to :starred_question, class_name: "Question", foreign_key: :question_id
end
