class Matcher
  
  # Step 1: Logistic availability (deal breaker!)

  # Divide into groups where at least one time in common

  # Group size as input

  def Matcher.calculate_group_size(options = {}) #group size will default to 3-4

    group_size = 0

    min_size = options[:min_size] ||= 3 
    max_size = options[:max_size] ||= 4
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

    return 'Group size is '+group_size.to_s+', and there will be one group with the size of '+(Student.all.length % group_size).to_s+'.'
  end
 
end