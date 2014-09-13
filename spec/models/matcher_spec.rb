require 'rails_helper'

RSpec.describe Matcher, :type => :model do

	it "creates feasible groups with a random algorithm" do
		puts 'Starting random algorithm testing at '+Time.now.to_s

		# create a bunch of students
		5.times { FactoryGirl.create(:student) } 

		puts 'Students created at '+Time.now.to_s
		# get started
		scores = Array.new
		counter = 0
		record_high = -999
		max_iterations = 2
		lowest_allowable_score = -10

		while(counter <= max_iterations) 
			new_random_group = Matcher.create_one_random_group
			new_score = DiversityScore.calculate_for_group(new_random_group)
			scores << new_score
			if new_score > 0 then break end
			new_random_group.destroy
			counter += 1
		end

		puts 'Checking scores now, at '+Time.now.to_s

		scores.each do |score|
			if score > record_high then record_high = score end
		end

		expect(record_high).to be > lowest_allowable_score
	end

end
