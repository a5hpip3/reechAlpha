class Notification < ActiveRecord::Base
  attr_accessible :from_user, :message, :to_user, :notification_type, :record_id, :read

  belongs_to :user, foreign_key: :to_user, primary_key: :reecher_id
end
