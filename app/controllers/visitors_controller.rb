class VisitorsController < ApplicationController
  def index
    @rows = RawSurveyToGroup.print_raw.drop(1)
    @header = RawSurveyToGroup.print_raw.first

    @students = Student.all.sort(availability: -1)
  end

  def groups
    @groups = Group.all
    @students = Student.all
  end
end
