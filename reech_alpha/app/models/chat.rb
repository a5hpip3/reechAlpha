class Chat < ActiveRecord::Base
  validates_presence_of :broadcasted_by
  #validates_presence_of :broadcasted_to
  validates_presence_of :message

  attr_accessor :status
  attr_accessible :status

  def broadcaster
  	User.find_by_reecher_id(self.broadcasted_by)
  end
end
