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

  describe '#duty_assigned' do
    duty_id = 1
    duty = Duty.new
    duty.duty_name= 'tester'
    it 'checking assigned duties' do
      allow(TeamsUser).to receive(:duty_by_team_user).with(1,1).and_return duty_id
      allow(Duty).to receive(:find).with(1).and_return duty
      student_teams_controller.duty_assigned 1, 1
    end
  end

  describe '#available_duties' do
    dutyIds = [1]
    duty1 = Duty.new
    duty1.multiple_duty= true

    duty2 = Duty.new
    duty2.multiple_duty= false


    it 'multiple_duty true' do
      allow(TeamsUser).to receive(:duties_by_team).with(1).and_return dutyIds
      allow(AssignmentsDuty).to receive(:duties_by_assignment).with(1).and_return dutyIds
      allow(Duty).to receive(:find).with(1).and_return duty1
      student_teams_controller.available_duties 1, 1
    end

    it 'multiple_duty false' do
      allow(TeamsUser).to receive(:duties_by_team).with(1).and_return dutyIds
      allow(AssignmentsDuty).to receive(:duties_by_assignment).with(1).and_return dutyIds
      allow(Duty).to receive(:find).with(1).and_return duty2
      student_teams_controller.available_duties 1, 1
    end
  end

  describe '#duties_allowed' do
    assignment = Assignment.new
    assignment.duty_flag=true
    it '#checking duties based assignment' do
      allow(Assignment).to receive(:find).with(1).and_return assignment
      allow(TeamsUser).to receive(:duty_by_team_user).with(1,1).and_return 1
      student_teams_controller.duties_allowed 1,1,1
    end
  end

  end
