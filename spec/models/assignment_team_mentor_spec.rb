describe AssignmentTeamMentor do

  let(:assignment_team_mentor)do
    AssignmentTeamMentor.new id: 1, assignment_team_id:1
  end
  let(:assignment_team_mentor2)do
    AssignmentTeamMentor.new id: 2, assignment_team_id:2
  end
  let(:team) { create(:assignment_team, id: 1, parent_id: 1) }
  let(:team2) { create(:assignment_team, id: 2, parent_id: 1) }
  let(:assignment) { build(:assignment, id: 1, name: 'with mentor')}

  describe 'validations'do
    context 'AssignmentTeamMentor valid with with '
  end

  describe '#assignMentor' do
    context 'when no participants are added to an assignment,' do
      it 'an error is raised' do
        expect(assignment_team_mentor.assignMentor(team[:parent_id])).to be_nil
      end
    end
    context 'when no participant who can mentor have been added to an assignment,' do
      it 'an error is raised' do
        mentor = Participant.new
        mentor.can_mentor = false
        mentor.parent_id = assignment.id
        mentor.save

        expect(assignment_team_mentor.assignMentor(team[:parent_id])).to be_nil
      end
    end
    context 'when participant mentors are added into an assignment' do
      it 'assigns assignment_team_mentor_id to a mentor_id' do
        mentor = Participant.new
        mentor.can_mentor = true
        mentor.parent_id = assignment.id
        mentor.save
        assignment_team_mentor.assignMentor(team[:parent_id])
        expect(assignment_team_mentor.assignment_team_mentor_id).to eq(mentor.id)
      end

      it 'assigns assignment-team_mentor_id to a mentor with the least amount of mentoring' do
        mentor = Participant.new
        mentor.can_mentor = true
        mentor.id = 1
        mentor.parent_id = assignment.id
        mentor.save

        atm = AssignmentTeamMentor.new
        atm.assignment_team_id = team.id
        atm.assignMentor(team[:parent_id])
        atm.save

        mentor2 = Participant.new
        mentor2.can_mentor = true
        mentor2.id = 2
        mentor2.parent_id = assignment.id
        mentor2.save

        atm2 = AssignmentTeamMentor.new
        atm2.assignment_team_id = team2.id
        atm2.assignMentor(team2[:parent_id])
        atm2.save
        expect(atm2.assignment_team_mentor_id).to eq(mentor2.id)
      end
    end
  end
end