class Student
  include Mongoid::Document
  field :student_num, type: String
  field :availability, type: String

  field :availability_d, type: Boolean
  field :availability_a, type: Boolean
  field :availability_n, type: Boolean

  field :gender, type: String
  field :years_fluency, type: Integer
  field :master, type: Mongoid::Boolean
  field :exchange, type: Mongoid::Boolean
  field :it_oriented, type: Mongoid::Boolean
  field :grade_guess, type: Integer
  field :hours_per_week, type: Integer
  field :introverted, type: Integer
  field :teamwork_ability, type: Integer
  field :teamwork_enjoyment, type: Integer
  field :survey_answered, type: DateTime
  field :overlap_hash, type: Hash

  belongs_to :group, dependent: :nullify
  has_and_belongs_to_many :overlap_scores

  validates_uniqueness_of :student_num
  validates_numericality_of :years_fluency, :grade_guess, :hours_per_week, :introverted, :teamwork_ability, :teamwork_enjoyment
  validates_length_of :student_num, minimum: 5, maximum: 10
  validates_presence_of :availability, :survey_answered, :student_num, :grade_guess, :hours_per_week, :availability_d, :availability_a, :availability_n


  def Student.prepare_unassigned_students_sorted_array
    unassigned_students = Array.new

    # load unassigned students into the unassigned_students array (instead of the lazy load mongoid search object)
    ua_students = Student.where(group_id: nil).order_by(:availability.asc) # return only those students that do not have a group

    # add items in array in reverse order for "pop" to work correctly

    # first, add the most flexible students into the bottom of the stack
    ua_students.each do |student|
      if student.availability.length == 3
        unassigned_students << student
      end
    end

    # second, add the second most flexible students into the bottom of the stack
    ua_students.each do |student|
      if student.availability.length == 2
        unassigned_students << student
      end
    end

    # last, add the most inflexible students on the top of the stack
    ua_students.each do |student|
      if student.availability.length == 1
        unassigned_students << student
      end
    end

    return unassigned_students

  end


  def Student.transform_survey_availability_to_char_string(survey_avail_string)
    student_availability = String.new

    if availability_string.include?('During')
      student_availability << 'D'
    end

    if availability_string.include?('After')
      student_availability << 'A'
    end

    if availability_string.include?('Non')
      student_availability << 'N'
    end

    return student_availability.to_s
  end

  def populate_availability_flags
    availability_string = self.availability

    raise 'Availability string is not populated!' if availability_string.length <= 0

    if availability_string.include?("D")
      self.availability_d = true
    else
      self.availability_d = false
    end

    if availability_string.include?("A")
      self.availability_a = true
    else
      self.availability_a = false
    end

    if availability_string.include?("N")
      self.availability_n = true
    else
      self.availability_n = false
    end

    raise 'Flag population failed!: '+availability_string.to_s unless ( self.availability_d = true || self.availability_a = true || self.availability_n = true )

    return true
  end

  def Student.ingest_csv
    dump = RawSurveyToGroup.dump_for_ingest

    header = dump.first
    array_of_students = dump.drop(1)

    array_of_students.each do |row|

      student = Student.new

      #
      #
      # => BEGIN PARSING EACH ROW OF STUDENT SURVEY DATA
      #
      #
      #
      #

      #Student number
      student.student_num = row[1].to_s

      #Student availability

      
      # Availability
      # first, transform the row data to the 'DAN' char string
      avail_string = Student.transform_survey_availability_to_char_string(row[2])

      # check that string has at least 'D', 'A' or 'N'
      raise 'Availability string is invalid' unless ( avail_string.include?('D') || avail_string.include?('A') || avail_string.include?('N') )
      
      # put this into the db record
      self.availability = avail_string

      # next, populate the availability true|false flags with the method
      student.populate_availability_flags

      #Student gender
      if row[3] == 'Female'
        student.gender = 'F'
      elsif row[3] == 'Other'
        student.gender = 'O'
      elsif row[3].length <= 0
        student.gender = ''
      else
        student.gender = 'M'
      end

      #Years of living in country with fluency
      student.years_fluency = Integer(row[4])

      #Is a master's student?
      if row[5] == 'Master'
        student.master = true
      elsif row[5] == 'Bachelor'
        student.master = false
      else
        raise 'Master / Bachelor missing!'
      end

      #Is an exchange student?
      if row[6] == 'No'
        student.exchange = false
      elsif row[6] == 'Yes'
        student.exchange = true
      else
        raise 'Exchange info missing!'
      end

      #Is the student IT savvy?
      if row[7] == 'Non-IT oriented'
        student.it_oriented = false
      elsif row[7] == 'IT oriented'
        student.it_oriented = true
      else
        raise 'IT orientation info missing!'
      end

      #Grade guess
      student.grade_guess = Integer(row[8])

      #Hours per week
      student.hours_per_week = Integer(row[9])

      #Extrovert/introvert
      if row[10] == 'Very Introverted'
        student.introverted = 1
      elsif row[10] == 'Introverted'
        student.introverted = 2
      elsif row[10] == ('Moderately Introverted')
        student.introverted = 3  
      elsif row[10] == 'Neutral'
        student.introverted = 4
      elsif row[10] == 'Moderately Extroverted'
        student.introverted = 5
      elsif row[10] == 'Extroverted'
        student.introverted = 6
      elsif row[10] == 'Very Extroverted'
        student.introverted = 7
      else
        raise 'Introvert/extrovert info missing!'
      end

      #Teamwork ability
      if row[11] == 'Very Poor'
        student.teamwork_ability = 1
      elsif row[11] == 'Poor'
        student.teamwork_ability = 2
      elsif row[11] == ('Moderately Poor')
        student.teamwork_ability = 3  
      elsif row[11] == 'Neutral'
        student.teamwork_ability = 4
      elsif row[11] == 'Moderately Good'
        student.teamwork_ability = 5
      elsif row[11] == 'Good'
        student.teamwork_ability = 6
      elsif row[11] == 'Very Good'
        student.teamwork_ability = 7
      else
        raise 'Teamwork ability info missing!'
      end

      #Teamwork enjoyment
      if row[12] == 'Very Poor'
        student.teamwork_enjoyment = 1
      elsif row[12] == 'Poor'
        student.teamwork_enjoyment = 2
      elsif row[12] == ('Moderately Poor')
        student.teamwork_enjoyment = 3  
      elsif row[12] == 'Neutral'
        student.teamwork_enjoyment = 4
      elsif row[12] == 'Moderately Good'
        student.teamwork_enjoyment = 5
      elsif row[12] == 'Good'
        student.teamwork_enjoyment = 6
      elsif row[12] == 'Very Good'
        student.teamwork_enjoyment = 7
      else
        raise 'Teamwork enjoyment info missing!'
      end

      #Split the awkward Google Docs timestamp format into something useful
      #"8.9.2014 klo 14.37.57" => [2014, 9, 8, 14, 37, 57] => #<DateTime: 2014-09-08T014:37:57+00:00 ...>
      date_n_time = row[0].split(' klo ')
      date = date_n_time[0].split('.')
      time = date_n_time[1].split('.')

      new_datetime = DateTime.new(date[2].to_i, date[1].to_i, date[0].to_i, time[0].to_i, time[1].to_i, time[2].to_i)
      student.survey_answered = new_datetime

      #All parsing DONE! 
      #Now save..

      student.save!
    end

    return array_of_students.length
  end

end