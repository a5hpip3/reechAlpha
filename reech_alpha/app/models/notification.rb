class Notification < ActiveRecord::Base
  attr_accessible :from_user, :message, :to_user
end
