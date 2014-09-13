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
    # --- not applicable due to group constraints

    #   3.3 [Mutation] With a mutation probability mutate new offspring at each locus (position in chromosome).
    new_feasible_population = GeneticMatcher.step_three_two_mutation(two_most_fit_parents)

    #   3.4 [Accepting] Place new offspring in a new population
    # 4. [Replace] Use new generated population for a further run of algorithm
    # 5. [Test] If the end condition is satisfied, stop, and return the best solution in current population
    # 6. [Loop] Go to step 2

  end

  def GeneticMatcher.mutate(population)
    new_population = Array.new

    # randomize the groups so that we can pick two random groups instead of the first two groups all the time
    population = population.to_a.shuffle

    # take the first two random groups out of the population
    counter = 2
    first_pop.each do |group|
      if counter > 0
        two_first_ones << group
      end
      counter -= 1
    end

    # so this is the first random group picked 
    first_first = Group.new

    # TODO: now we need to do the swap of students between two groups (from the same population to avoid duplicates or omissions of students!)

    #first_first.students = 

    # << two_first_ones[0].students.to_a.shuffle.first
    #two_first_ones[1].students.to_a.shuffle.first

    return new_population
  end

  def GeneticMatcher.step_three_two_mutation(two_most_fit_parents)
    new_feasible_population = Array.new

    first_pop = two_most_fit_parents.pop
    second_pop = two_most_fit_parents.pop

    # check out what the highest score is of the most fit parents
    highest_score = 0
    if first_pop[:min_score] > highest_score then highest_score = first_pop[:min_score] end
    if second_pop[:min_score] > highest_score then highest_score = second_pop[:min_score] end 

    # take two random groups in a population, and create a new population, where people in these two groups are switched between each other

    # shuffle the first population's groups and take the first two, and then create a new population where these two ones have switched members
    first_pop = first_pop[:sample] #.shuffle (??)
    second_pop = second_pop[:sample]

    # TODO: this is wrong! should only return something if the new mutation is better than the original!

    # so do a score check for both new (first & second) new populations
    
    new_feasible_population << GeneticMatcher.mutate(first_pop)
    new_feasible_population << GeneticMatcher.mutate(second_pop)

    return new_feasible_population
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
