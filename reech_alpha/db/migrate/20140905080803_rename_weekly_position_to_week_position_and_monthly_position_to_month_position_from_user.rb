class RenameWeeklyPositionToWeekPositionAndMonthlyPositionToMonthPositionFromUser < ActiveRecord::Migration

  def change
    rename_column :users, :weekly_position, :week_position
    rename_column :users, :monthly_position, :month_position
  end

end
