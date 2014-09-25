class PreviewSolution < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :user_id, :solution_id
  validates_uniqueness_of :user_id, scope: :solution_id
  belongs_to :user
  belongs_to :solution
end
