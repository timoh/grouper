class Group
  include Mongoid::Document

  has_many :students, dependent: :nullify

  field :diversity_score, type: Integer
  field :size, type: Integer

  validates_presence_of :students

  before_update :calculate_diversity_score
  before_update :calculate_size

  def Group.calculate_group_size(options = {}) #group size will default to 4-5
    student_count = Student.all.length
    group_size = 0

    min_size = options[:min_size] ||= 4 
    max_size = options[:max_size] ||= 5

    # ensure that both min_size and max_size are set to some sensible value
    unless min_size > 0 && max_size > 0 then raise 'Group size constraints not set!' end

    min_modulo = student_count % min_size
    max_modulo = student_count % max_size

    # this if statement is the core of the method: it sets the group size so that the modulos fit between the min and max size
    if max_modulo >= min_size && max_modulo <= max_size
      group_size = min_size
    elsif max_modulo >= min_size && max_modulo <= max_size
      group_size = max_size
    else
      puts 'Max modulo: '+max_modulo.to_s+' vs. max size: '+max_size.to_s
      puts 'Min modulo: '+min_modulo.to_s+' vs. min size: '+min_size.to_s

      raise 'We now have a situation where this algorithm cannot solve the correct group size!'
    end

    return group_size

  end

  protected
  def calculate_diversity_score
    score = DiversityScore.calculate_for_group(self)
    self.diversity_score = score
  end

  def calculate_size
    self.size = self.students.count
  end
end
