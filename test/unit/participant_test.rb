require File.dirname(__FILE__) + '/../test_helper'


class ParticipantTest < ActiveSupport::TestCase
	fixtures :participants
	fixtures :courses
	fixtures :assignments
	
	def test_add_participant()
		participant = Participant.new
		
		#TODO Should an empty Participant be allowed?
		# assert !participant.valid?
		#TODO Define requerid fields in test and add those validations to the model so test passes.
		
		assert participant.valid?
	end
	
	def test_add_course_participant()
		participant = CourseParticipant.new
		
		#TODO read TODO tag in lines 11-13
		
		assert participant.valid?
	end
	
	def test_add_assignment_participant()
		participant = AssignmentParticipant.new
		assert !participant.valid?
		
		#TODO read TODO tag in line 13
		
		participant.handle = 'test_handle'
		assert participant.valid?
	end
	
	def test_delete_not_force
		participant = participants(:par1)
		participant.delete
		assert participant.valid?
	end
end
