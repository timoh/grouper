require 'rails_helper'

RSpec.describe DiversityScore, :type => :model do
  
  it "it calculates a score for a group" do
    group = FactoryGirl.create(:group)
    score = DiversityScore.calculate_for_group(group)

    expect(score).to be_a(Fixnum)

  end
end
