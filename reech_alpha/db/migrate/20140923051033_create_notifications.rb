class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :from_user
      t.string :to_user
      t.text :message

      t.timestamps
    end
  end
end
