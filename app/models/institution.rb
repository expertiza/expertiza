class Institution < ActiveRecord::Base
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name
end
