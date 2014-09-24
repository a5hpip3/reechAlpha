class Notification < ActiveRecord::Base
  attr_accessible :from_user, :message, :to_user, :notification_type, :record_id
end
