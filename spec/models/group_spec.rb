require 'rails_helper'

RSpec.describe Group, :type => :model do
  
  it "calculates the optimal group size with parameters" do
    DatabaseCleaner.clean
    19.times { FactoryGirl.create(:student) }

    group_size = Group.calculate_group_size(options = { :min_size => 4, :max_size => 5 })
    expect(group_size).to be_a(Fixnum)
    expect(group_size).to be >= 4
    expect(group_size).to be <= 5

  end

  it "calculates the optimal group size without parameters" do
    DatabaseCleaner.clean
    19.times { FactoryGirl.create(:student) }

    group_size = Group.calculate_group_size
    expect(group_size).to be_a(Fixnum)
    expect(group_size).to be > 1

  end

end
