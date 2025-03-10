class CourseAnalyticTestDummyClass
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
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:participant) { build(:participant, user: build(:student, username: 'Jane', name: 'Doe, Jane', id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, username: 'John', name: 'Doe, John', id: 2)) }
  let(:participant3) { build(:participant, can_review: false, user: build(:student, username: 'King', name: 'Titan, King', id: 3)) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:assignment2) { build(:assignment, id: 2, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:assignment3) { build(:assignment, id: 3, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }

  describe '#num_participants' do
    context 'when the course has no students in it' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.num_participants).to eq(0)
      end
    end
    context 'when the course has three students in it' do
      it 'should return three' do
        dc = CourseAnalyticTestDummyClass.new(course, [participant, participant2, participant3], [])
        expect(dc.num_participants).to eq(3)
      end
    end
  end
  describe '#num_assignments' do
    context 'when the course has no assignments in it' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.num_assignments).to eq(0)
      end
    end
    context 'when the course has three assignments in it' do
      it 'should return three' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        expect(dc.num_assignments).to eq(3)
      end
    end
  end
  describe '#total_num_assignment_teams' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.total_num_assignment_teams).to eq(0)
      end
    end
    context 'when there are three assignments with each having one team' do
      it 'returns three' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
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
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.average_num_assignment_teams).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one team, one has two, and one has three' do
      it 'returns two' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:num_teams).and_return(1)
        allow(assignment2).to receive(:num_teams).and_return(2)
        allow(assignment3).to receive(:num_teams).and_return(3)
        expect(dc.average_num_assignment_teams).to eq(2)
      end
    end
  end
  describe '#max_num_assignment_teams' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.max_num_assignment_teams).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one team, one has two, and one has three' do
      it 'returns three' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:num_teams).and_return(1)
        allow(assignment2).to receive(:num_teams).and_return(2)
        allow(assignment3).to receive(:num_teams).and_return(3)
        expect(dc.max_num_assignment_teams).to eq(3)
      end
    end
  end
  describe '#min_num_assignment_teams' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.min_num_assignment_teams).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one team, one has two, and one has three' do
      it 'returns one' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:num_teams).and_return(1)
        allow(assignment2).to receive(:num_teams).and_return(2)
        allow(assignment3).to receive(:num_teams).and_return(3)
        expect(dc.min_num_assignment_teams).to eq(1)
      end
    end
  end
  describe '#average_assignment_score' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.average_assignment_score).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has a 95, and one has a 100' do
      it 'returns 95' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:average_team_score).and_return(90)
        allow(assignment2).to receive(:average_team_score).and_return(95)
        allow(assignment3).to receive(:average_team_score).and_return(100)
        expect(dc.average_assignment_score).to eq(95)
      end
    end
  end
  describe '#max_assignment_score' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.max_assignment_score).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has a 95, and one has a 100' do
      it 'returns 100' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:max_team_score).and_return(90)
        allow(assignment2).to receive(:max_team_score).and_return(95)
        allow(assignment3).to receive(:max_team_score).and_return(100)
        expect(dc.max_assignment_score).to eq(100)
      end
    end
  end
  describe '#min_assignment_score' do
    context 'when there are no assignments' do
      it 'returns zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.min_assignment_score).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has a 95, and one has a 100' do
      it 'returns 90' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:min_team_score).and_return(90)
        allow(assignment2).to receive(:min_team_score).and_return(95)
        allow(assignment3).to receive(:min_team_score).and_return(100)
        expect(dc.min_assignment_score).to eq(90)
      end
    end
  end
  describe '#assignment_review_counts' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.assignment_review_counts).to eq([0])
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return list of [1,2,3]' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:total_num_team_reviews).and_return(1)
        allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
        allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
        expect(dc.assignment_review_counts).to eq([1, 2, 3])
      end
    end
  end
  describe '#total_num_assignment_reviews' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.total_num_assignment_reviews).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return six' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:total_num_team_reviews).and_return(1)
        allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
        allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
        expect(dc.total_num_assignment_reviews).to eq(6)
      end
    end
  end
  describe '#average_num_assignment_reviews' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.average_num_assignment_reviews).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return two' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:total_num_team_reviews).and_return(1)
        allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
        allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
        expect(dc.average_num_assignment_reviews).to eq(2)
      end
    end
  end
  describe '#max_num_assignment_reviews' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.max_num_assignment_reviews).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return three' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:total_num_team_reviews).and_return(1)
        allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
        allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
        expect(dc.max_num_assignment_reviews).to eq(3)
      end
    end
  end
  describe '#min_num_assignment_reviews' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.min_num_assignment_reviews).to eq(0)
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return one' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:total_num_team_reviews).and_return(1)
        allow(assignment2).to receive(:total_num_team_reviews).and_return(2)
        allow(assignment3).to receive(:total_num_team_reviews).and_return(3)
        expect(dc.min_num_assignment_reviews).to eq(1)
      end
    end
  end
  describe '#assignment_team_count' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.assignment_team_counts).to eq([0])
      end
    end
    context 'three assignments have been added to the course, and one has one review, one has two, and one has three' do
      it 'should return [1,2,3]' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:num_teams).and_return(1)
        allow(assignment2).to receive(:num_teams).and_return(2)
        allow(assignment3).to receive(:num_teams).and_return(3)
        expect(dc.assignment_team_counts).to eq([1, 2, 3])
      end
    end
  end
  describe '#assignment_average_scores' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.assignment_average_scores).to eq([0])
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has 95, and one has 100' do
      it 'should return [90,95,100]' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:average_team_score).and_return(90)
        allow(assignment2).to receive(:average_team_score).and_return(95)
        allow(assignment3).to receive(:average_team_score).and_return(100)
        expect(dc.assignment_average_scores).to eq([90, 95, 100])
      end
    end
  end
  describe '#assignment_max_scores' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.assignment_max_scores).to eq([0])
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has 95, and one has 100' do
      it 'should return [90,95,100]' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:max_team_score).and_return(90)
        allow(assignment2).to receive(:max_team_score).and_return(95)
        allow(assignment3).to receive(:max_team_score).and_return(100)
        expect(dc.assignment_max_scores).to eq([90, 95, 100])
      end
    end
  end
  describe '#assignment_min_scores' do
    context 'there have been no assignments added to a course' do
      it 'should return zero' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [])
        expect(dc.assignment_min_scores).to eq([0])
      end
    end
    context 'three assignments have been added to the course, and one has a 90, one has 95, and one has 100' do
      it 'should return [90,95,100]' do
        dc = CourseAnalyticTestDummyClass.new(course, [], [assignment, assignment2, assignment3])
        allow(assignment).to receive(:min_team_score).and_return(90)
        allow(assignment2).to receive(:min_team_score).and_return(95)
        allow(assignment3).to receive(:min_team_score).and_return(100)
        expect(dc.assignment_min_scores).to eq([90, 95, 100])
      end
    end
  end
end
