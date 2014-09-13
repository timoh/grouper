require 'rails_helper'

RSpec.describe Student, :type => :model do
  
  it "prepares an array of all students that do not have a group" do
    DatabaseCleaner.clean

    19.times { FactoryGirl.create(:student) }
    expect(Student.all.length).to equal 19

    ua_students_array = Student.prepare_unassigned_students_array

    ua_students_array.each do |student|
      expect(student.group).to eq nil
    end

    expect(ua_students_array.size).to equal 19

  end

end
