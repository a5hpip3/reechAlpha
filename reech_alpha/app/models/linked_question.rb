class LinkedQuestion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user, :foreign_key => 'user_id', :primary_key => 'reecher_id'
  belongs_to :question, :foreign_key => 'question_id', :primary_key => 'question_id'
  belongs_to :linked_by, class_name: 'User', foreign_key: 'linked_by_uid', primary_key: 'reecher_id'
end
