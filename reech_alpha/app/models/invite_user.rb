class InviteUser < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :linked_question
end
