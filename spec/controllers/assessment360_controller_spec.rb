describe Assessment360Controller do
  let(:instructor) { build(:instructor, id: 6) }
  let(:course) { double('Course', id: 1, name: 'Test Course') }
  let(:user) { double('User', id: 1) }

  describe '#combined_course_summary' do
    before(:each) do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      allow(Course).to receive(:find).with('1').and_return(course)
    end

    it 'redirects with error when course has no participants' do
      assignments = []
      allow(assignments).to receive(:includes).and_return(assignments)
      allow(course).to receive(:assignments).and_return(assignments)
      
      participants = []
      allow(participants).to receive(:includes).and_return([])
      allow(course).to receive(:get_participants).and_return(participants)

      get :combined_course_summary, params: { course_id: '1' }

      expect(flash[:error]).to eq("There is no course participant in course Test Course")
      expect(response).to redirect_to(root_path)
    end
    it 'renders template when course has participants' do
      participant = double('Participant', id: 1, user_id: 1)
      assignment = double('Assignment', id: 1, course_id: 1, is_calibrated: false)
    
      # Mock participants for assignment (to avoid .find_by error)
      assignment_participants_relation = double('AssignmentParticipantsRelation')
      allow(assignment_participants_relation).to receive(:empty?).and_return(false)
      allow(assignment_participants_relation).to receive(:find_by).with(user_id: 1).and_return(participant)
      allow(assignment).to receive(:participants).and_return(assignment_participants_relation)
    
      assignments = [assignment]
      allow(assignments).to receive(:includes).and_return(assignments)
      allow(course).to receive(:assignments).and_return(assignments)
    
      participants = [participant]
      allow(participants).to receive(:includes).and_return([participant])
      allow(course).to receive(:get_participants).and_return(participants)
    
      allow(participant).to receive(:user).and_return(user)
      allow(participant).to receive(:teammate_reviews).and_return([])
      allow(participant).to receive(:metareviews).and_return([])
    
      teams_users_relation = double('TeamsUser::ActiveRecord_Relation')
      allow(TeamsUser).to receive(:where).and_return(teams_users_relation)
      allow(teams_users_relation).to receive(:includes).with(:team).and_return([])
    
      allow(StudentTask).to receive(:teamed_students).and_return({1 => []})
    
      get :combined_course_summary, params: { course_id: '1' }
    
      expect(response).to render_template(:course_summary)
    end
  end
end