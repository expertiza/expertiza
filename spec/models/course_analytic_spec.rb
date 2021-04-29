class DummyClass 
	attr_accessor :course, :participants, :assignments
	require 'analytic/course_analytic'
	include CourseAnalytic
	
	def initialize(course, participants, assignments)
		@course = course
		@participants = participants
		@assignments = assignments
	end
 	
end

describe CourseAnalytic do
	let(:course) { build(:course, id: 1, name: 'ECE517')}
	let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, name: "John", fullname: "Doe, John", id: 2)) }
  let(:participant3) { build(:participant, can_review: false, user: build(:student, name: "King", fullname: "Titan, King", id: 3)) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:assignment2) { build(:assignment, id: 2, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:assignment3) { build(:assignment, id: 3, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }

	describe '#num_participants' do
		context 'when the course has no students in it' do
			it 'should return zero' do
				dc = DummyClass.new(course, [], [])
				expect(dc.num_participants).to eq(0)
			end
		end
		context 'when the course has three students in it' do
			it 'should return three' do
				dc = DummyClass.new(course, [participant, participant2, participant3], [])
				expect(dc.num_participants).to eq(3)
			end
		end
	end
	describe '#num_assignments' do
		context 'when the course has no assignments in it' do
			it 'should return zero' do
				dc = DummyClass.new(course, [], [])
				expect(dc.num_assignments).to eq(0)
			end
		end
		context 'when the course has three assignments in it' do
			it 'should return three' do
				dc = DummyClass.new(course, [], [assignment, assignment2, assignment3])
				expect(dc.num_assignments).to eq(3)
			end
		end
	end
	describe '#total_num_assignment_teams' do
		context 'when there are no assignments' do
			it 'returns zero' do
				dc = DummyClass.new(course, [], [])
				expect(dc.total_num_assignment_teams).to eq(0)
			end
		end
		context 'when there are three assignments with each having one team' do
			it 'returns three' do
				dc = DummyClass.new(course, [], [assignment, assignment2, assignment3])
				allow(assignment).to receive(:num_teams).and_return(1)
				allow(assignment2).to receive(:num_teams).and_return(1)
				allow(assignment3).to receive(:num_teams).and_return(1)
				expect(dc.total_num_assignment_teams).to eq(3)
			end
		end
	end
	describe '#average_num_assignment_teams' do
		context 'when there are no assignments' do
			it 'returns zero' do
				dc = DummyClass.new(course, [], [])
				expect(dc.average_num_assignment_teams).to eq(0)
			end
		end
		context 'three assignments have been added to the course, and one has one team, one has two, and one has three' do
			it 'returns two' do
				dc = DummyClass.new(course, [], [assignment, assignment2, assignment3])
				allow(assignment).to receive(:num_teams).and_return(1)
				allow(assignment2).to receive(:num_teams).and_return(2)
				allow(assignment3).to receive(:num_teams).and_return(3)
				expect(dc.average_num_assignment_teams).to eq(2)
			end
		end
	end
	describe '#average_num_assignment_reviews' do
		context 'there have been no assignments added to a course' do
			it 'should return zero' do
				dc = DummyClass.new(course, [], [])
				expect(dc.average_num_assignment_reviews).to eq(0)
			end
		end
		context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
			it 'should return two' do
				dc = DummyClass.new(course, [], [assignment, assignment2, assignment3])
				allow(assignment).to receive(:total_num_team_reviews).and_return(1)
				allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
				allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
				expect(dc.average_num_assignment_reviews).to eq(2)
			end
		end
	end
end