require 'rails_helper'

describe 'CourseTeam' do
  let(:course_team1) { build(:course_team, id: 1, name: 'no team') }
  let(:user2) { build(:student, id: 2, name: 'no name') }
  let(:participant) { build(:participant, user: user2) }
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:team_user) { build(:team_user, id: 1, user: user2) }
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }

  describe 'copy course team to assignment team' do
    it 'should allow course team to be copied to assignment team' do
      assignment = build(Assignment)
      assignment.name = 'test'
      assignment.save!
      assignment_team = AssignmentTeam.new
      assignment_team.save
      course_team = CourseTeam.new
      course_team.copy(assignment_team.id)
      expect(AssignmentTeam.create_team_and_node(assignment_team.id))
      expect(assignment_team.copy_members(assignment_team.id))
    end
  end

  describe '#parent_model' do
    it 'returns parent_model' do
      course_team = CourseTeam.new
      expect(course_team.parent_model).to eq('Course')
    end
  end

  describe '#assignment_id' do
    it 'returns nil since this team is not an assignment team' do
      course_team = CourseTeam.new
      expect(course_team.assignment_id).to be_nil
    end
  end

  describe '#prototype' do
    it 'creates a course team' do
      expect(CourseTeam.prototype.class).to eq(CourseTeam)
    end
  end

  describe '#add_participant' do
    it 'adds a participant to the course when it is not already added' do
      allow(CourseParticipant).to receive(:find_by).with(parent_id: 1, user_id: 2).and_return(nil)
      allow(CourseParticipant).to receive(:create).with(parent_id: 1, user_id: 2, permission_granted: 0).and_return(participant)
      expect(course_team1.add_participant(1, user2)).to eq(participant)
    end
  end

  describe '#import' do
    context 'when the course does not exist' do
      it 'raises an import error' do
        allow(Course).to receive(:find).with(1).and_return(nil)
        expect { CourseTeam.import({}, 1, nil) }.to raise_error(ImportError)
      end
    end

    context 'when the course does exist' do
      it 'raises an error with empty row hash' do
        allow(Course).to receive(:find).with(1).and_return(course)
        expect { CourseTeam.import({}, 1, nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#export' do
    it 'writes to a csv' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1])
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_user])
      expect(CourseTeam.export([], 1, team_name: 'false')).to eq([['no team', 'no name']])
    end
  end

  describe '#export_fields' do
    it 'returns a list of headers' do
      expect(CourseTeam.export_fields(team_name: 'false')).to eq(['Team Name', 'Team members', 'Course Name'])
    end
  end

  describe '#add_member' do
    it 'adds a member to the course team' do
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      allow(TeamsParticipant).to receive(:create).with(participant_id: 1, team_id: 1).and_return(team_participant)
      expect(course_team1.add_member(team_participant.participant)).to be true
    end
  end

  describe '#remove_member' do
    it 'removes a member from the course team' do
      allow(TeamsParticipant).to receive(:find_by).with(team_id: 1, participant_id: 1).and_return(team_participant)
      expect(course_team1.remove_member(team_participant.participant)).to be true
    end
  end

  describe '#user?' do
    it 'checks if a user is a member of the course team' do
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      expect(course_team1.user?(team_participant.participant.user)).to be true
    end
  end

  describe '#full?' do
    it 'checks if the course team is full' do
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      expect(course_team1.full?).to be false
    end
  end

  describe '#size' do
    it 'returns the size of the course team' do
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      expect(course_team1.size).to eq(1)
    end
  end

  describe '#copy_members' do
    it 'copies members from one course team to another' do
      new_team = build(:course_team, id: 2)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      allow(TeamsParticipant).to receive(:create).with(team_id: 2, participant_id: 1).and_return(team_participant)
      course_team1.copy_members(new_team)
      expect(TeamsParticipant).to have_received(:create).with(team_id: 2, participant_id: 1)
    end
  end
end
