class DeadlineType < ActiveRecord::Base
	has_many :assignment_due_dates, class_name: 'AssignmentDueDate', foreign_key: 'deadline_type_id'
	has_many :topic_due_dates, class_name: 'TopicDueDate', foreign_key: 'deadline_type_id'


	def email_list(assignment_id)
		raise NotImplementedError, 'You must implement the email_list method'
	end
	
end


