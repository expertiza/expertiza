class MarkupStyle < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: true
  attr_accessible :name
end
