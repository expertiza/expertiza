describe StudentTeamsController do
  let (:student_teams_controller) { StudentTeamsController.new }
  let(:student) { double "student" }
  describe '#view' do
    it 'sets the student' do
      allow(AssignmentParticipant).to receive(:find).with('12345').and_return student
      allow(student_teams_controller).to receive(:current_user_id?)
      allow(student_teams_controller).to receive(:params).and_return(student_id: '12345')
      allow(student).to receive(:user_id)
      student_teams_controller.view
    end
  end

  describe 'test invitation criteria' do
    before(:each) do
      # create assignment
      # add student to assignment
    end
    it 'returns false is student doesn\'t have a team' do
      # make sure student doesn't have a team
      # assert false
    end
    it 'returns false if current team size is 1 and assignment\'s allowed team size is also 1' do
      # specify assignment team size to be 1
      # create team for student
      # assert false
    end
    it 'returns true if assignment\'s allowed team size is > 1 and current team size is less than allowed team size' do
      # specify assignment team size to be greater than 1
      # create team for assignment and keep number of team members less than allowed
      # assert true
    end
    it 'returns false if current team size is equal allowed team size' do
      # specify any assignment team size
      # create team for assignment and keep number of team members equal to allowed
      # assert false
    end
    it 'returns false if assignment is in finished stage' do
      # change deadline of assignment to be in past
      # assert false
    end
    it 'returns true if assignment is not in finished stage' do
      # change deadline of assignment to be in future
      # specify assignment team size to be greater than 1
      # create team for assignment and keep number of team members less than allowed
      # assert true
    end
    it 'assigns only student without teams and with one member teams to @participant_map if invitation criteria is true' do
      # set invitation criteria to be true
      # add few participants with no team to the assignment
      # add few participants with single member team to the assignment
      # assert length of map to be equal to number of valid participants
    end
    it 'checks for empty @participant_map if invitation criteria is true and all students has team with more than 1 member' do
      # set invitation criteria to be true
      # add few participants with single member team to the assignment
      # assert length of map to be equal to 0
    end
    it 'checks for empty @participant_map if invitation criteria is false ' do
      # set invitation criteria to be false
      # assert length of map to be equal to number of valid participants
    end
  end
end
