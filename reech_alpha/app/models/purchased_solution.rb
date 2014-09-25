class PurchasedSolution < ActiveRecord::Base
  #attr_accessible :solution_id, :user_id
  belongs_to :user
  belongs_to :solution
  validates_uniqueness_of :user_id, scope: :solution_id

  scope :questions, ->(arg) do
  	joins(:solution).where(:user_id => arg).includes(:solution).pluck("solutions.question_id")
  end
end
