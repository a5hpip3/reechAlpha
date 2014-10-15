class Vote < ActiveRecord::Base
  belongs_to :solution, :foreign_key => "votable_id"
  belongs_to :user, :foreign_key => "voter_id"
end
