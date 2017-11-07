class MarkupStyle < ActiveRecord::Base
  attr_accessible
  validates_presence_of :name
  validates_uniqueness_of :name
end
