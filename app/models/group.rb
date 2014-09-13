class Group
  include Mongoid::Document

  has_many :students, dependent: :nullify

  field :diversity_score, type: Integer
  field :size, type: Integer

  validates_presence_of :students

  before_save :calculate_diversity_score
  before_save :calculate_size

  protected
  def calculate_diversity_score
    score = DiversityScore.calculate_for_group(self)
    self.diversity_score = score
  end

  def calculate_size
    self.size = self.students.count
  end
end
