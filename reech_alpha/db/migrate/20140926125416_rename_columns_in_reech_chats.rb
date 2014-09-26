class RenameColumnsInReechChats < ActiveRecord::Migration
  def up
  	rename_column :reech_chats, :from_user, :from_user_id
  	rename_column :reech_chats, :to_user, :to_user_id
  end

  def down
  end
end
