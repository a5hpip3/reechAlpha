class ChangeReechChatsColumnName < ActiveRecord::Migration
  def up
  	rename_column :reech_chats, :question_id, :solution_id
  end

  def down
  end
end
