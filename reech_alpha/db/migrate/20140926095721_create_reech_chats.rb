class CreateReechChats < ActiveRecord::Migration
  def change
    create_table :reech_chats do |t|
      t.string :from_user
      t.string :to_user
      t.string :question_id
      t.text :message

      t.timestamps
    end
  end
end
