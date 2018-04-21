class Duty < ActiveRecord::Base
	belongs_to :instructor, class_name: 'User'
	belongs_to :assignment, class_name: 'Assignment'
	validates :name, presence: true, uniqueness: {scope: :assignment_id}
end
