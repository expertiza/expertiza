class Section < ActiveRecord::Base

  validates_uniqueness_of :name,:message => "Section name has been already used"
end
