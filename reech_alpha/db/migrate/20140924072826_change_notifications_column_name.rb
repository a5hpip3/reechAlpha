class ChangeNotificationsColumnName < ActiveRecord::Migration
  def up
  	rename_column :notifications, :type, :notification_type
  end

  def down
  end
end
