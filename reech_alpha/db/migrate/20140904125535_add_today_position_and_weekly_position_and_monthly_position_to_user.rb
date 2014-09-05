class AddTodayPositionAndWeeklyPositionAndMonthlyPositionToUser < ActiveRecord::Migration
  def change
    add_column :users, :today_position, :float
    add_column :users, :weekly_position, :float
    add_column :users, :monthly_position, :float
  end
end
