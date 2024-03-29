require 'csv'

class RawSurveyToGroup
  
  def RawSurveyToGroup.generate_digest(filename) # generates digest out of the header row, NOT whole file, to check that the headers haven't changed .. content should be allowed to change!
    file = CSV.read(filename)
    return Digest::SHA2.hexdigest(file.first.join(',')).to_s
  end

  def RawSurveyToGroup.compare_to_earlier_digest(filename)
    RawSurveyToGroup.generate_digest(filename) == RawSurveyToGroup.saved_digest ? true : false
  end

  def RawSurveyToGroup.saved_digest
    return "45f8652fac8f0bc55e7e21d5df88757af8272215b6e99e85799fa1336f097952"
  end

  def RawSurveyToGroup.read_file(options = {}) #set your own CSV filename
    options[:filename] ||= "./public/survey.csv"
    return CSV.read(options[:filename])
  end

  def RawSurveyToGroup.print_raw
    file = RawSurveyToGroup.read_file
    raise 'Filename digest has changed' unless RawSurveyToGroup.compare_to_earlier_digest("./public/survey.csv")
    return file
  end

  def RawSurveyToGroup.dump_for_ingest
    file = RawSurveyToGroup.read_file
    raise 'Filename digest has changed' unless RawSurveyToGroup.compare_to_earlier_digest("./public/survey.csv")

    return file
  end

end
