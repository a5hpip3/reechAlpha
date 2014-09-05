class DropLeaderBoardTable < ActiveRecord::Migration
  def change
    drop_table :leader_boards
  end
end
