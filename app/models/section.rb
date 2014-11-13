class Section < ActiveRecord::Base
  has_many :questions
  validates_uniqueness_of :name,:message => "Section name has been already used"
end
