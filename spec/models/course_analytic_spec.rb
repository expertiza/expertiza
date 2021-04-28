class DummyClass 
	attr_accessor :course
	require 'analytic/course_analytic'
	include CourseAnalytic
	
	def initialize(course)
		@course = course
	end
 	
 	def count_of_parts
    num_participants
 	end

end

describe CourseAnalytic do
	let(:course) { build(:course, id: 1, name: 'ECE517')}
	
	describe '#num_participants' do
		context 'when the course has no students in it' do
			it 'should return zero' do
				dc = DummyClass.new(course)
				allow(course).to receive(:participants).and_return([])
				expect(dc.count_of_parts).to eq(0)
			end
		end
	end
end