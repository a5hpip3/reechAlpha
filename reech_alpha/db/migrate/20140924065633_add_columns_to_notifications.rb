class AddColumnsToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :type, :string
  	add_column :notifications, :read, :boolean, default: false
  	add_column :notifications, :record_id, :string
  end
end
