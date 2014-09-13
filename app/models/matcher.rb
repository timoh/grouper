class Matcher

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
    group_size = Group.calculate_group_size

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
    group_size = Group.calculate_group_size(options = {:min_size => 4, :max_size => 5})

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

      end

  end
 
end