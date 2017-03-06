json.extract! goal,
              :id,
              :description,
              :frequency,
              :created_at,
              :updated_at,
              :longest_streak_length

json.url goal_url(goal, format: :json)
