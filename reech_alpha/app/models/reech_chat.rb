class ReechChat < ActiveRecord::Base
  attr_accessor :status
  attr_accessible :from_user_id, :message, :solution_id, :to_user_id, :status
  belongs_to :from_user, class_name: "User", primary_key: "id", foreign_key: "from_user_id"
  belongs_to :to_user, class_name: "User", primary_key: "id", foreign_key: "to_user_id"
  belongs_to :solution
end
