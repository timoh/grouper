class OverlapScore
  include Mongoid::Document

  field :score, type: Integer

  has_and_belongs_to_many :students # should have two scores each
end
