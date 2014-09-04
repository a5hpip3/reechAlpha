class CreateLeaderBoards < ActiveRecord::Migration
  def change
    create_table :leader_boards do |t|
      t.references :user
      t.float :question_count
      t.float :answer_count
      t.float :hi5_count
      t.float :curios
      t.float :position
      t.datetime :current_date

      t.timestamps
    end
    add_index :leader_boards, :user_id
  end
end
