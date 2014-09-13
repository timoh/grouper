# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :student do
    student_num { rand.to_s[2..6] }

    # availability population

    availability {
        avail = Array.new
        while (avail.length <= 0)
            ["D", "A", "N"].each do |value|
                pick = [true, false].sample
                if pick then avail << value end
            end
        end

        avail
    }

    gender { 

        # also populate the availability flags while we're at it..
        self.populate_availability_flags

        ["F", "M"].sample 
    }
    years_fluency { rand.to_s[2..2].to_i }
    master { [true, false].sample }
    exchange { [true, false].sample }
    it_oriented { [true, false].sample }
    grade_guess { (1..5).to_a.sample }
    hours_per_week { (4..15).to_a.sample } 
    introverted { (1..7).to_a.sample }
    teamwork_ability { (1..7).to_a.sample }
    teamwork_enjoyment { (1..7).to_a.sample }
    survey_answered "2014-09-08 15:18:28"
  end
end
