json.extract! goal, :id, :description, :frequency, :longest_streak_length

json.url goal_url(goal, format: :json)
json.latest_streak goal.latest_streak
