class AddBlurbToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :blurb, :text
  end
end
