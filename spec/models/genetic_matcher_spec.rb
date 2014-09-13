require 'rails_helper'

RSpec.describe GeneticMatcher, :type => :model do
  
  it "starts the process by creating random groups" do
    DatabaseCleaner.clean
    19.times { FactoryGirl.create(:student) }

    expect( Group.all.size ).to eq 0

    GeneticMatcher.step_one_start 

    expect( Group.all.size ).to be > 0
    expect( Student.first.group ).to be_truthy
  end

end
