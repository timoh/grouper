class VisitorsController < ApplicationController
  def index
    @rows = RawSurveyToGroup.print_raw.drop(1)
    @header = RawSurveyToGroup.print_raw.first
  end
end
