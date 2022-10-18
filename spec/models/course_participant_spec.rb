describe 'CourseParticipant' do
  describe '#copy' do
    before(:each) do
      @assignment = build(:assignment)
      @course_participant = build(:course_participant)
      @assignment_participant = build(:participant)
    end

    it 'create a copy of participant' do
      allow(AssignmentParticipant).to receive(:create).and_return(@assignment_participant)
      allow(@assignment_participant).to receive(:set_handle).and_return(true)
      expect(@course_participant.copy(@assignment.id)).to be_an_instance_of(AssignmentParticipant)
    end

    it 'returns nil if copy exist' do
      allow(AssignmentParticipant).to receive(:where).and_return(AssignmentParticipant)
      allow(AssignmentParticipant).to receive(:first).and_return(@assignment_participant)
      allow(@assignment_participant).to receive(:set_handle).and_return(true)

      expect(@course_participant.copy(@assignment.id)).to be_nil
    end
  end

  describe '#import' do
    it 'raise error if record is empty' do
      row = []
      expect { CourseParticipant.import(row, nil, nil, nil) }.to raise_error('No user id has been specified.')
    end

    it 'raise error if record does not have enough items ' do
      row = { name: 'user_name', fullname: 'user_fullname', email: 'name@email.com' }
      expect { CourseParticipant.import(row, nil, nil, nil) }.to raise_error("The record containing #{row[:name]} does not have enough items.")
    end

    it 'raise error if course with id not found' do
      course = build(:course)
      session = {}
      row = []
      allow(Course).to receive(:find).and_return(nil)
      allow(session[:user]).to receive(:id).and_return(1)
      row = { name: 'user_name', fullname: 'user_fullname', email: 'name@gmail.com', password: 'user_password' }
      expect { CourseParticipant.import(row, nil, session, 2) }.to raise_error('The course with the id "2" was not found.')
    end

    it 'creates course participant form record' do
      course = build(:course)
      session = {}
      row = []
      allow(Course).to receive(:find).and_return(course)
      allow(session[:user]).to receive(:id).and_return(1)
      row = { name: 'user_name', fullname: 'user_fullname', email: 'name@email.com', role: 'user_role_name', parent: 'user_parent_name' }
      course_part = CourseParticipant.import(row, nil, session, 2)
      expect(course_part).to be_an_instance_of(CourseParticipant)
    end
  end

  describe '#export' do
    it 'checks if csv file is created' do
      options = { 'personal_details' => 'true' }
      course_participant = create(:course_participant)
      course_participant[:parent_id] = 2
      CSV.open('t.csv', 'ab') do |csv|
        CourseParticipant.export(csv, 2, options)
      end
    end
  end

  describe '#export_fields' do
    it 'option is empty fields is empty' do
      fields = []
      options = {}
      expect(CourseParticipant.export_fields(options)).to be_empty
    end

    it 'option is not empty fields is not empty' do
      fields = []
      options = { 'personal_details' => 'true' }
      fields = CourseParticipant.export_fields(options)
      expect(fields).not_to be_empty
    end
  end
end
