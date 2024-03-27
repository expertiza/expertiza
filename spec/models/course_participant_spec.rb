describe 'CourseParticipant' do
  let(:course) { build (:course) }

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

  describe '.import' do
    context 'when record is empty' do
      it 'raises an ArgumentError' do
        expect { CourseParticipant.import({}, nil, nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when the record does not have required items' do
      it 'raises an ArgumentError' do
        row = { name: 'no one', fullname: 'no one' }
        expect { CourseParticipant.import(row, nil, 1) }.to raise_error(ArgumentError)
      end
    end

    context 'when no user is found by provided username' do
      context 'when the record has required items' do
        let(:row) do
          { name: 'no one', fullname: 'no one', email: 'name@email.com' }
        end
        before(:each) do
          user = double('User', :id => 1, :nil? => true)
          allow(User).to receive(:find_by).with(:name => 'no one').and_return(user)
          allow(User).to receive(:import).with(any_args).and_return(user)
        end

        context 'when course cannot be found' do
          it 'creates a new user then raises an ImportError' do
            allow(Course).to receive(:find_by).with(1).and_return(nil)
            expect(User).to receive(:import).with(any_args)
            expect { CourseParticipant.import(row, nil, 1) }.to raise_error(ImportError, 'The course with id 1 was not found.')
          end
        end

        context 'when course found and course participant does not exist' do
          it 'creates a new user and participant' do
            allow(Course).to receive(:find_by).with(1).and_return(course)
            allow(CourseParticipant).to receive(:exists?).with(user_id: 1, parent_id: 1).and_return(false)
            expect(User).to receive(:import).with(any_args)
            expect(CourseParticipant).to receive(:create).with(user_id: 1, parent_id: 1)
            CourseParticipant.import(row, nil, 1)
          end
        end
      end
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
