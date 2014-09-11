class DiversityScore

  def DiversityScore.calculate_for_group(group)

    diversity_score = 0

    # calculate hard constraints
    # 1. availability
    d_available = true
    a_available = true
    n_available = true

    # important:
    # 1. gender (0 or 2+ of a specific gender in same group)
    female_count = 0
    male_count = 0

    # 2. master / bachelor
    master_count = 0
    bach_count = 0

    # 3. exchange?
    exchange_count = 0

    # 4. IT-orientedness
    it_count = 0
    non_it_count = 0

    #
    # SOFTER PREFERENTIAL SCORES
    #
    
    group.students.each do |student|

      # for each student, set group availability of certain time range to false even if only one cannot make that time range
      unless student.availability_d then d_available = false end
      unless student.availability_a then a_available = false end
      unless student.availability_n then n_available = false end 

      # least important: calculate preferential attributes
      diversity_score += ((student.years_fluency.to_i - group.students.avg(:years_fluency).to_i).abs).to_i
      diversity_score += ((student.introverted.to_i - group.students.avg(:introverted).to_i).abs).to_i
      diversity_score += ((student.teamwork_ability.to_i - group.students.avg(:teamwork_ability).to_i).abs).to_i
      diversity_score += ((student.teamwork_enjoyment.to_i - group.students.avg(:teamwork_enjoyment).to_i).abs).to_i
    end

    raise 'Size of group should not be zero!' if group.students.size <= 0

    diversity_score = (diversity_score / group.students.size.to_i).to_i

    #
    # THESE PREFERENTIAL SCORES SHOULD VARY AS LITTLE SINCE OTHERWISE PEOPLE HAVE VERY DIFFERENT EXPECTATIONS
    #

    # 5. grade guess
    diversity_score -= group.students.max(:grade_guess).to_i - group.students.min(:grade_guess).to_i

    # 6. hours available
    diversity_score -= group.students.max(:hours_per_week).to_i - group.students.min(:hours_per_week).to_i

    #
    # HARDER CONSTRAINTS
    #



    # group needs to have availability
    unless d_available || a_available || n_available then diversity_score = -999 end
    # either zero or 2+ members of same sex in group
    if female_count == 1 || male_count == 1 then diversity_score = -999 end

    #penalty for having too many exchange students in same group
    if exchange_count > 1 then diversity_score -= (exchange_count*10) end

    #smaller penalty for not conforming to non_it / it alonenesss
    if it_count == 1 || non_it_count == 1 then diversity_score -= -3 end 

    #smaller penalty for not conforming to master / bachelor aloneness
    if master_count == 1 || bach_count == 1 then diversity_score -= 3 end

    return diversity_score

  end

end
