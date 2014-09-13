class GeneticMatcher


  def GeneticMatcher.do_match

    # 1. [Start] Generate random population of n chromosomes (suitable solutions for the problem)
    # 2. [Fitness] Evaluate the fitness f(x) of each chromosome x in the population
    # 3. [New population] Create a new population by repeating following steps until the new population is complete
    #   3.1 [Selection] Select two parent chromosomes from a population according to their fitness (the better fitness, the bigger chance to be selected)
    #   3.2 [Crossover] With a crossover probability cross over the parents to form a new offspring (children). If no crossover was performed, offspring is an exact copy of parents.
    #   3.3 [Mutation] With a mutation probability mutate new offspring at each locus (position in chromosome).
    #   3.4 [Accepting] Place new offspring in a new population
    # 4. [Replace] Use new generated population for a further run of algorithm
    # 5. [Test] If the end condition is satisfied, stop, and return the best solution in current population
    # 6. [Loop] Go to step 2

  end

  def GeneticMatcher.step_one_start # 1. [Start] Generate random population of n chromosomes (suitable solutions for the problem)
    Group.destroy_all
    students = Student.all.to_a
    options = {:min_size => 4, :max_size => 5}
    group_size = Group.calculate_group_size(options)
    group_count = (students.size / group_size.to_f).ceil

    group_count.times { 
      grp = Group.new 
      group_size.times {  
        grp.students << students.pop
      }
      grp.save!
    }

    raise 'Something is wrong ... '+students.size.to_s if students.size > 0
    return Group.all.size
  end
  
end
