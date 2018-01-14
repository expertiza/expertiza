class Permission < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :content_pages
  has_many :controller_actions
end
