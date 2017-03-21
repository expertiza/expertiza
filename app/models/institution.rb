class Institution < ActiveRecord::Base
  validates_length_of :name, minimum: 1
  validates_uniqueness_of :name
  # Establishing relationship between Course and Institution
  has_many :courses, dependent: :destroy
end
