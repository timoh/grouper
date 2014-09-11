class Matcher
  
  # Step 1: Logistic availability (deal breaker!)

  # Divide into groups where at least one time in common

  # Group size as input

  def Matcher.create_feasible_ordered_groups_iteratively
    start_time = Time.new
    record_high = -999
    iterations = 0

    while(Matcher.prepare_unassigned_students_array.size > 0)
      iterations += 1

      group = Matcher.create_one_sorted_group
      outcome = DiversityScore.calculate_for_group(group)

      unless DiversityScore.calculate_for_group(group) > 0 then group.destroy end
      if outcome > record_high then record_high = outcome end
      if (iterations % 10 == 0) then puts iterations.to_s+' iterations passed at '+Time.new.to_s+', latest outcome is '+outcome.to_s+' and the record is '+record_high.to_s+'.' end

      # start over if iterations don't help the result
      if (iterations % 25 == 0) then Group.destroy_all end

    end

    puts 'Unassigned students: '+Matcher.prepare_unassigned_students_array.size.to_s
    puts 'Groups: '+Group.all.count.to_s
    puts 'Smallest group score: '+Group.min(:diversity_score).to_s

  end


  def Matcher.create_feasible_groups_iteratively
    start_time = Time.new
    record_high = -999
    iterations = 0

    while(Matcher.prepare_unassigned_students_array.size > 0)
      iterations += 1

      group = Matcher.create_one_group
      outcome = DiversityScore.calculate_for_group(group)

      unless DiversityScore.calculate_for_group(group) > 0 then group.destroy end
      if outcome > record_high then record_high = outcome end
      if (iterations % 10 == 0) then puts iterations.to_s+' iterations passed at '+Time.new.to_s+', latest outcome is '+outcome.to_s+' and the record is '+record_high.to_s+'.' end

      # start over if iterations don't help the result
      if (iterations % 25 == 0) then Group.destroy_all end

    end

    puts 'Unassigned students: '+Matcher.prepare_unassigned_students_array.size.to_s
    puts 'Groups: '+Group.all.count.to_s
    puts 'Smallest group score: '+Group.min(:diversity_score).to_s

  end

  def Matcher.create_one_random_group(options = {}) # default group size is 5
    unassigned_students = Matcher.prepare_unassigned_students_array

    if unassigned_students.size <= 0 then raise '0 unassigned students -- cannot create a new group!' end

    group_size = options[:group_size] ||= 5

    while(unassigned_students.length > 0)
      group = Group.new
      group_full = false

      while(!group_full)
        group.students << unassigned_students.pop
        group.save!

        if unassigned_students.length <= 0 then break end
        if group.students.count >= group_size then group_full = true end
        #puts 'Group current size: '+group.size.to_s+' vs. max group size: '+group_size.to_s
      end

        if group.students.count > 0
          return group
        else
          raise 'Group size is not big enough!'
        end
    end
  end


  #
  #
  # TODO!!!! ... missing the logic of ensuring that each student that is pulled from the array, would work as a feasible part of the group
  # ..otherwise should be left in the array and processed later
  #
  #

  def Matcher.create_one_sorted_group(options = {})
    unassigned_students = Matcher.prepare_unassigned_students_sorted_array

    if unassigned_students.size <= 0 then raise '0 unassigned students -- cannot create a new group!' end

    group_size = options[:group_size] ||= 5

    while(unassigned_students.length > 0)
      group = Group.new
      group_full = false

      while(!group_full)

        # iterate over the remaining students and only pop students which are feasible

        # unassigned_students.each_pair do |key, value|
        #     # TODO!!!!
        # end

        group.students << unassigned_students.pop
        group.save!

        if unassigned_students.length <= 0 then break end
        if group.students.count >= group_size then group_full = true end
        #puts 'Group current size: '+group.size.to_s+' vs. max group size: '+group_size.to_s
      end

        if group.students.count > 0
          return group
        else
          raise 'Group size is not big enough!'
        end
    end
  end


  def Matcher.prepare_unassigned_students_sorted_array
    unassigned_students = Array.new

    # load unassigned students into the unassigned_students array (instead of the lazy load mongoid search object)
    ua_students = Student.where(group_id: nil).order_by(:availability, 1) # return only those students that do not have a group

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


  def Matcher.group_and_count
    infeasible_groups = true
    outcome = 0
    start_time = Time.new
    record_high = -999
    iterations = 0

    puts 'Starting grouping algorithm at '+start_time.to_s

    while(infeasible_groups)
      iterations += 1
      outcome = Matcher.calc_group_scores_for_all_arrays(Matcher.create_random_groups)
      if outcome > record_high then record_high = outcome end
      if outcome > 0 then infeasible_groups false end
      if (iterations % 10 == 0) then puts iterations.to_s+' iterations passed at '+Time.new.to_s+', latest outcome is '+outcome.to_s+' and the record is '+record_high.to_s+'.' end
    end

    return outcome

  end

  def Matcher.calc_group_scores_for_all_arrays(all_groups)
      Group.destroy_all

      all_groups.each do |group|

        new_group = Group.new

        group.each do |student|
          new_group.students << student
        end

        new_group.save!
        new_group.diversity_score = DiversityScore.calculate_for_group(new_group)
        new_group.save!
      end

      return Group.min(:diversity_score).to_i

  end

  def Matcher.prepare_unassigned_students_array
    unassigned_students = Array.new

    # load unassigned students into the unassigned_students array (instead of the lazy load mongoid search object)
    ua_students = Student.in(group_id: nil) # return only those students that do not have a group
    ua_students.each do |student|
      unassigned_students << student
    end

    # shuffle the array with Ruby's array shuffling functionality
    unassigned_students = unassigned_students.shuffle

    return unassigned_students

  end

  def Matcher.create_random_groups
    all_groups = Array.new

    # prepare randomized array of unassigned students
    unassigned_students = Matcher.prepare_unassigned_students_array

    # find optimal size for groups
    group_size = Matcher.calculate_group_size

    while(unassigned_students.length > 0)
      group = Array.new
      group_full = false

      while(!group_full)
        group << unassigned_students.pop

        if unassigned_students.length <= 0 then break end
        if group.size >= group_size then group_full = true end
        #puts 'Group current size: '+group.size.to_s+' vs. max group size: '+group_size.to_s
      end

        if group.size > 0
          all_groups << group
        end

        #puts 'Amount of unassigned students: '+unassigned_students.size.to_s
    end

    return all_groups

  end

  def Matcher.create_groups
    group_size = Matcher.calculate_group_size(options = {:min_size => 4, :max_size => 5})

    # attempt to maximize logistical availability overlap by starting to attempt to create a team from those who have maximum overlap (each member has a minimum overlap score with each team member that is as high as possible)
      Matcher.calculate_overlap_scores

      #then create groups with the needed size, where you maximize the minimum overlapscore
      all_scores = OverlapScore.all.sort(score: -1) # descending order
      
      students_without_group = 0 # see how many students are missing a group
      Student.all.each do |student|
        unless student.group?
          students_without_group = students_without_group + 1
        end
      end

      puts students_without_group.to_s+' students missing a group that will now receive a group.'

      while (students_without_group > 0)
        spots_in_group = group_size # initialize counter for creating a new group
        new_group = Group.new

        puts '---- Creating new group: '+new_group.id.to_s

        while(spots_in_group > 0)

          OverlapScore.all.sort(score: -1).each do |score| # go through all scores until all students have a group

            score.students.each do |student|

              unless student.group?
                puts 'Adding '+student.student_num+' to group '+new_group.id.to_s+'.'
                new_group.students << student
                new_group.save!
                student.save!

                students_without_group = students_without_group-1
                spots_in_group = spots_in_group-1
                puts 'Spots in group decreased by one, now '+spots_in_group.to_s
                if spots_in_group == 0
                  break
                end

              else
                #puts 'Student '+student.student_num.to_s+' already has a group: '+student.group.id.to_s
              end

              if spots_in_group == 0
                  break
              end

            end

            if spots_in_group == 0
                  break
            end

          end

          puts 'Students without a group: '+students_without_group.to_s

          if spots_in_group == 0 || students_without_group == 0
                  break
          end

          

        end

        puts 'New group has been formed with '+new_group.students.join(",")+' students.'

        # now we have filled a group and must create a new group

      end

    # if the size of the potential group is smaller than the min group size, then we have to start joining groups

    # ensure there is no group where there is only one of a specific gender (either 0 or 2+ of each gender)

  end

  def Matcher.count_all_group_scores
    Group.all.each do |group|
      Matcher.count_group_score(group)
    end
  end


  def Matcher.count_group_score(group)
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

  def Matcher.calculate_group_size(options = {}) #group size will default to 4-5

    group_size = 0

    min_size = options[:min_size] ||= 4 
    max_size = options[:max_size] ||= 5
    # walk_order = options[:order] ||= 'ASC'

    # if walk_order == 'ASC'
    #   while(group_size == 0)



    #   end
    # else # DESC
    #   while(group_size == 0)

    #   end 
    # end

    min_modulo = Student.all.length % min_size
    max_modulo = Student.all.length % max_size

    if min_modulo >= min_size && min_modulo <= max_size
      group_size = min_size
    elsif max_modulo >= min_size && max_modulo <= max_size
      group_size = max_size
    else
      raise 'We now have a situation where this algorithm cannot solve the correct group size!'
    end

    # puts 'Group size is '+group_size.to_s+', and there will be one group with the size of '+(Student.all.length % group_size).to_s+'.'
    return group_size

  end
 

  def Matcher.calculate_overlap_scores
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

end