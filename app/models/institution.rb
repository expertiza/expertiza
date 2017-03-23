class Institution < ActiveRecord::Base
  has_many :courses

  validates_length_of :name, minimum: 1
  validates_uniqueness_of :name
end
