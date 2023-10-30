# app/helpers/due_date_helper.rb

module DueDateHelper
	def self.deadline_sort(due_dates)
	  due_dates.sort do |m1, m2|
		if m1.due_at && m2.due_at
		  m1.due_at <=> m2.due_at
		elsif m1.due_at
		  -1
		else
		  1
		end
	  end
	end
  
	def self.done_in_assignment_round(assignment_id, response)
	  return 0 if ResponseMap.find(response.map_id).type != 'ReviewResponseMap'
  
	  due_dates = DueDate.where(parent_id: assignment_id)
	  sorted_deadlines = deadline_sort(due_dates)
	  due_dates.reject { |due_date| due_date.deadline_type_id != 1 && due_date.deadline_type_id != 2 }
	  round = 1
	  sorted_deadlines.each do |due_date|
		break if response.created_at < due_date.due_at
  
		round += 1 if due_date.deadline_type_id == 2
	  end
	  round
	end
  end
  
