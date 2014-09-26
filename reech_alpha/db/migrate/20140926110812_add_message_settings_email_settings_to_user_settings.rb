class AddMessageSettingsEmailSettingsToUserSettings < ActiveRecord::Migration
  def change
  	add_column :user_settings, :email_settings, :text
  	add_column :user_settings, :message_settings, :text
  end
end
