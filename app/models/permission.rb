class Permission < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true
  validates :name, uniqueness: true

<<<<<<< HEAD
  has_many :content_pages, dependent: :nullify
  has_many :controller_actions, dependent: :nullify
=======
  has_many :content_pages, dependent: :destroy
  has_many :controller_actions, dependent: :destroy
>>>>>>> Rahul and Shraddha Code Climate Fixes
end
