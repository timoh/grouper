# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
  	
  	students {
  		studs = Array.new
  		5.times {
  			studs << FactoryGirl.create(:student)
  		}
  		studs
  	}

  end
end
