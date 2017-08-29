class AnonymizedLastName < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: true
  attr_accessible
end
