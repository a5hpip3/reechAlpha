class AddScoresToUser < ActiveRecord::Migration
  def change
    add_column :users, :scores, :text
  end
end
