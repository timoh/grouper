# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :student do
    student_num "MyString"
    availability "MyString"
    gender "MyString"
    years_fluency 1
    master false
    exchange false
    it_oriented false
    grade_guess 1
    hours_per_week 1
    introverted 1
    teamwork_ability 1
    teamwork_enjoyment 1
    survey_answered "2014-09-08 15:18:28"
  end
end
