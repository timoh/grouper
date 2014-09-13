class OverlapScore
  include Mongoid::Document

  field :score, type: Integer

  has_and_belongs_to_many :students # should have two scores each
end

def OverlapScore.count_all_group_scores
    Group.all.each do |group|
      Matcher.count_group_score(group)
    end
  end


  def OverlapScore.count_group_score(group)
    # count minimum overlap score of group
      # for each group, show overlap scores per student vs other students
      lowest_score = 0

      puts '----- Scores for group '+group.id.to_s
      puts 'Group has '+group.students.count.to_s+' members.'

      group.students.each do |student| # take all students in the group
        group_students_ids = Array.new 

        student.group.students.each do |other_group_student| #find the student DB id's of each student into an array
          unless other_group_student == student 
            group_students_ids << student.id
          end
        end

        group_students_ids.each do |student_id| # iterate over these DB id's of students 
          student.overlap_scores.where(student_ids: student_id).each do |score| # for each of the group's students, look for scores with each of the other students
            if (score.score? && score.score < lowest_score && score.score >= 0)
              lowest_score = score.score 
            end
          end
        end

      end

      puts 'Lowest score in the group was: '+lowest_score.to_s

  end

  def OverlapScore.calculate_overlap_scores
    # calculate overlap score (0-n), so that if there is no overlap (= no possibility), then the score is 0, and otherwise the score is the amount of overlapping slots
    students = Student.all

    score_count = OverlapScore.all.count
    student_product = Student.all.count * Student.all.count

    if score_count == student_product
      return false
    end

    students.each do |student|
      # for each student, calculate an overlap score with the other students

      students.each do |other_student|
        score_already_calculated = false # only attempt to create new calculation if doesn't already exist

        student.overlap_scores.each do |existing_score|

          if (existing_score.students.where(id: other_student.id).count > 0)
            score_already_calculated = true 
          end
        end 

        unless score_already_calculated # given that the check previously found no matches, do the calculation for this pair
          overlap_score = OverlapScore.new
          overlap_score.score = 0 # initialize value

          overlap_score.students << student # setup host
          overlap_score.students << other_student # setup the other

          # so now, calculate overlap scores with each student

          student.availability.to_s.chars.each do |char|
            # let's say we compare a 'DA' with a 'N'
            if other_student.availability.include?(char) # say, if 'D' is included in 'N' then increment overlap, otherwise do nothing
              overlap_score.score = overlap_score.score + 1
            end
          end

          overlap_score.save!
          puts 'Students '+overlap_score.students.join(',') + 'have the score of '+overlap_score.score.to_s

        end

      end

      student.save! #save the overlap hash
      puts 'Student '+student.student_num+' now has '+student.overlap_scores.length.to_s+' scores calculated'

    end


    puts 'Total count of scores is : '+ OverlapScore.count.to_s

  end