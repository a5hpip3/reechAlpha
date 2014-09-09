class AddIsPublic < ActiveRecord::Migration
  def up
    add_column  :solutions, :is_public, :boolean ,:default =>1,:after=>:ask_charisma
  end

  def down
  end
end
