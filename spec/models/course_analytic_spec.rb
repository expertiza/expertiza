class DummyClass 
	attr_accessor :course
	attr_accessor :participants
	require 'analytic/course_analytic'
	include CourseAnalytic
	
	def initialize(course, participants)
		@course = course
		@participants = participants
	end
 	
 	def count_of_parts
    num_participants
 	end

end

describe CourseAnalytic do
	let(:course) { build(:course, id: 1, name: 'ECE517')}
	let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, name: "John", fullname: "Doe, John", id: 2)) }
  let(:participant3) { build(:participant, can_review: false, user: build(:student, name: "King", fullname: "Titan, King", id: 3)) }
	describe '#num_participants' do
		context 'when the course has no students in it' do
			it 'should return zero' do
				dc = DummyClass.new(course, [])
				expect(dc.count_of_parts).to eq(0)
			end
		end
		context 'when the course has three students in it' do
			it 'should return three' do
				dc = DummyClass.new(course, [participant, participant2, participant3])
				expect(dc.count_of_parts).to eq(3)
			end
		end
	end
end