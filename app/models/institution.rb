class Institution < ActiveRecord::Base
  attr_accessible :name
  has_many :courses, dependent: :destroy

  validates_length_of :name, minimum: 1
  validates_uniqueness_of :name
end
