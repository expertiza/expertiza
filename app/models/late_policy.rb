class LatePolicy < ActiveRecord::Base

  belongs_to :user

  has_many :assignments

  validates_presence_of :policy_name
  validates_presence_of :instructor_id

end
