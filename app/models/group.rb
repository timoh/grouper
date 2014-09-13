class Group
  include Mongoid::Document

  has_many :students, dependent: :nullify

  field :diversity_score, type: Integer

  validates_presence_of :students

  before_save :calculate_diversity_score

  def Group.calculate_group_size(options = {}) #group size will default to 4-5

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

  protected
  def calculate_diversity_score
    score = DiversityScore.calculate_for_group(self)
    self.diversity_score = score
  end
end
