class Group
  include Mongoid::Document

  has_many :students
end
