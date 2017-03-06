class AddLongestStreakToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :longest_streak_length, :bigint, null: false, default: 0
  end
end
