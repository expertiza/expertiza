class Permission < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :content_pages
  has_many :controller_actions
end
