class Duty < ActiveRecord::Base
	belongs_to :instructor, class_name: 'User'
	belongs_to :assignment, class_name: 'Assignment'
	validates :name, presence: true
	validates :name, uniqueness: {scope: :course_id}
    
end
