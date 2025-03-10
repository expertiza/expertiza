describe CourseTeam do
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:course_team1) { build(:course_team, id: 1) }
  let(:course_team2) { build(:course_team, id: 2) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:user2) { User.new name: 'bcd', fullname: 'cbd ccd', email: 'bcdccd@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:participant) { build(:participant, user: build(:student, name: 'Jane', fullname: 'Doe, Jane', id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, name: 'John', fullname: 'Doe, John', id: 2)) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }

  describe 'validations' do
    it 'validates presence of name' do
      course.name = ''
      expect(course).not_to be_valid
    end
    it 'validates presence of directory_path' do
      # course is built with the default directory_path 'csc517/test' in factories.rb
      course.directory_path = ''
      expect(course).not_to be_valid
    end
  end

  describe '#get_teams' do
    it 'returns the associated teams with the course' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1, course_team2])
      expect(course.get_teams.length).to eq(2)
      expect(course.get_teams).to eq([course_team1, course_team2])
    end
  end
  describe '#path' do
    context 'when there is no associated instructor' do
      it 'an error is raised' do
        allow(course).to receive(:instructor_id).and_return(nil)
        expect { course.path }.to raise_error('Path can not be created. The course must be associated with an instructor.')
      end
    end
    context 'when there is an associated instructor' do
      it 'returns a directory' do
        allow(course).to receive(:instructor_id).and_return(6)
        allow(User).to receive(:find).with(6).and_return(user1)
        expect(course.path.directory?).to be_truthy
      end
    end
  end
  describe '#get_participants' do
    it 'returns associated participants' do
      allow(CourseParticipant).to receive(:where).with(parent_id: 1).and_return([participant, participant2])
      expect(course.get_participants.length).to eq(2)
      expect(course.get_participants).to eq([participant, participant2])
    end
  end
  describe '#get_participant' do
    it 'returns a specific participant from the user id' do
      allow(CourseParticipant).to receive(:where).with(parent_id: 1, user_id: 2).and_return([participant2])
      expect(course.get_participant(2)).to eq([participant2])
    end
  end
  describe '#add_participant' do
    context 'when the user cannot be found' do
      it 'returns an error and requests that the user creates a user with the username' do
        allow(User).to receive(:find_by).with(name: 'bcd').and_return(nil)
        allow(course).to receive(:url_for).and_return('users/new')
        expect { course.add_participant('bcd') }.to raise_error(RuntimeError)
      end
    end
    context 'if the user is already added to the course' do
      it 'returns an error that the user is already a participant' do
        allow(User).to receive(:find_by).with(name: 'abc').and_return(user1)
        allow(user1).to receive(:id).and_return(1)
        allow(CourseParticipant).to receive(:where).with(parent_id: 1, user_id: 1).and_return([participant])
        expect { course.add_participant('abc') }.to raise_error('The user abc is already a participant.')
      end
    end
    context 'the user can be added successfully' do
      it 'returns a participant to the course' do
        allow(User).to receive(:find_by).with(name: 'abc').and_return(user1)
        allow(user1).to receive(:id).and_return(1)
        allow(CourseParticipant).to receive(:where).with(parent_id: 1, user_id: 1).and_return([nil])
        allow(CourseParticipant).to receive(:create).with(parent_id: 1, user_id: 1, permission_granted: 0).and_return(participant)
        expect(course.add_participant('abc')).to eq(participant)
      end
    end
  end
  describe '#copy_participants' do
    context 'when there are errors' do
      it 'raises an error to the user' do
        allow(AssignmentParticipant).to receive(:where).with(parent_id: 1).and_return([participant, participant2])
        allow(User).to receive(:find).with(1).and_return(user1)
        allow(User).to receive(:find).with(2).and_return(user2)
        allow(participant).to receive(:user_id).and_return(1)
        allow(participant2).to receive(:user_id).and_return(2)
        allow(course).to receive(:add_participant).with('abc').and_raise('The user abc is already a participant.', StandardError)
        allow(course).to receive(:add_participant).with('bcd').and_raise('The user bcd is already a participant.', StandardError)
        expect { course.copy_participants(1) }.to raise_error(TypeError)
      end
    end
    context 'when there are no errors' do
      it 'the participants are added to the course' do
        allow(AssignmentParticipant).to receive(:where).with(parent_id: 1).and_return([participant, participant2])
        allow(User).to receive(:find).with(1).and_return(user1)
        allow(User).to receive(:find).with(2).and_return(user2)
        allow(participant).to receive(:user_id).and_return(1)
        allow(participant2).to receive(:user_id).and_return(2)
        allow(course).to receive(:add_participant).with('abc').and_return(participant)
        allow(course).to receive(:add_participant).with('bcd').and_return(participant2)
        allow(course).to receive(:participants).and_return([participant, participant2])
        expect(course.copy_participants(1)).to eq(nil)
        expect(course.participants.length).to eq(2)
      end
    end
  end

  describe '#user_on_team?' do
    context 'when the user is not on a team associated with the assignment' do
      it 'returns false' do
        allow(course).to receive(:teams).and_return([course_team1])
        allow_any_instance_of(Team).to receive(:users).and_return([user1])
        expect(course.user_on_team?(user2)).to be_falsey
      end
    end
    context 'when the user is on a team associated with the assignment' do
      it 'returns true' do
        allow(course).to receive(:get_teams).and_return([course_team1])
        allow_any_instance_of(CourseTeam).to receive(:users).and_return([user1, user2])
        expect(course.user_on_team?(user2)).to be_truthy
      end
    end
  end
end
