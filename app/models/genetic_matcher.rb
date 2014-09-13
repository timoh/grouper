class GeneticMatcher


  def GeneticMatcher.do_match

    # 1. [Start] Generate random population of n chromosomes (suitable solutions for the problem)
    initial_batch = GeneticMatcher.step_one_start(10)

    # 2. [Fitness] Evaluate the fitness f(x) of each chromosome x in the population
    initial_results = GeneticMatcher.step_two_fitness(initial_batch)
    
    # 3. [New population] Create a new population by repeating following steps until the new population is complete
    #   3.1 [Selection] Select two parent chromosomes from a population according to their fitness (the better fitness, the bigger chance to be selected)
    two_most_fit_parents = GeneticMatcher.step_three_one_selection(initial_results)

    #   3.2 [Crossover] With a crossover probability cross over the parents to form a new offspring (children). If no crossover was performed, offspring is an exact copy of parents.
    #   3.3 [Mutation] With a mutation probability mutate new offspring at each locus (position in chromosome).
    #   3.4 [Accepting] Place new offspring in a new population
    # 4. [Replace] Use new generated population for a further run of algorithm
    # 5. [Test] If the end condition is satisfied, stop, and return the best solution in current population
    # 6. [Loop] Go to step 2

  end

  def GeneticMatcher.step_three_two_crossover(two_most_fit_parents)

  end

  def GeneticMatcher.step_three_one_selection(earlier_batch)
    two_most_fit_parents = Array.new

    scores = Array.new

    highest_score = 0

    earlier_batch.each do |population| # find highest score value
      if population[:min_score] > highest_score then highest_score = population[:min_score] end
    end

    earlier_batch.each do |population| # find the winner
      if population[:min_score] == highest_score then two_most_fit_parents << population end
    end

    second_highest_score = 0

    earlier_batch.each do |population| # find second highest score value
      if population[:min_score] > second_highest_score && population != two_most_fit_parents.first then second_highest_score = population[:min_score] end
    end

    earlier_batch.each do |population| # find the second
      if population[:min_score] == second_highest_score then two_most_fit_parents << population end
    end

    return two_most_fit_parents
  end

  def GeneticMatcher.step_two_fitness(population_array)
    population_scores = Array.new

    population_array.each do |groups|
      minimum_score = -999
      population_sample = Array.new

      groups.each do |group|
        new_score = DiversityScore.calculate_for_group(group)
        if new_score >= minimum_score then minimum_score = new_score end
        population_sample << { :group => group, :score => new_score }
      end

      population_scores << { :sample => population_sample, :min_score => minimum_score }
    end

    return population_scores

  end

  def GeneticMatcher.step_one_start(pop_size) # 1. [Start] Generate random population of n chromosomes (suitable solutions for the problem)
    population = Array.new

    pop_size.times {
      groups_array = Array.new
      students = Student.all.to_a.shuffle
      options = {:min_size => 4, :max_size => 5}
      group_size = Group.calculate_group_size(options)
      group_count = (students.size / group_size.to_f).ceil

      group_count.times { 
        grp = Group.new 
        group_size.times {  
          grp.students << students.pop
        }
        grp.save!
        groups_array << grp
      }

      raise 'Something is wrong ... '+students.size.to_s if students.size > 0
      population << groups_array
    }

    return population
  end


  
end
