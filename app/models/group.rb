class Group
  include Mongoid::Document

  has_many :students, dependent: :nullify

  field :diversity_score, type: Integer

  validates_presence_of :students

  before_save :calculate_diversity_score

  protected
  def calculate_diversity_score
    score = DiversityScore.calculate_for_group(self)
    self.diversity_score = score
  end
end
