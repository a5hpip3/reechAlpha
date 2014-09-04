class LeaderBoard < ActiveRecord::Base
  belongs_to :user
  attr_accessible :answer_count, :curios, :hi5_count, :question_count
end
