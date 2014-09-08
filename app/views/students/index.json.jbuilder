json.array!(@students) do |student|
  json.extract! student, :id, :student_num, :availability, :gender, :years_fluency, :master, :exchange, :it_oriented, :grade_guess, :hours_per_week, :introverted, :teamwork_ability, :teamwork_enjoyment, :survey_answered
  json.url student_url(student, format: :json)
end
