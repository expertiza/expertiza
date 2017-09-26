describe Assignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, name: 'no one') }
  let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
  let(:teammate_review_response_map) { build(:review_response_map, type: 'TeammateReviewResponseMap') }
  let(:participant) { build(:participant, id: 1) }
  let(:question) { double('Question') }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:response) { build(:response) }
  let(:course) { build(:course) }
  let(:assignment_due_date) do
    build(:assignment_due_date, due_at: '2011-11-11 11:11:11 UTC', deadline_name: 'Review',
                                description_url: 'https://expertiza.ncsu.edu/', round: 1)
  end
  let(:topic_due_date) { build(:topic_due_date, deadline_name: 'Submission', description_url: 'https://github.com/expertiza/expertiza') }

  describe '.max_outstanding_reviews' do
    it 'returns 2 by default'
  end

  describe '#team_assignment?' do
    it 'checks an assignment has team'
  end

  describe '#has_topics?' do
    context 'when sign_up_topics array is not empty' do
      it 'says current assignment has topics'
    end

    context 'when sign_up_topics array is empty' do
      it 'says current assignment does not have a topic'
    end
  end

  describe '.set_courses_to_assignment' do
    it 'fetches all courses belong to current instructor and with the order of course names'
  end

  describe '#has_teams?' do
    context 'when teams array is not empty' do
      it 'says current assignment has teams'
    end

    context 'when sign_up_topics array is empty' do
      it 'says current assignment does not have a team'
    end
  end

  describe '#valid_num_review' do
    context 'when num_reviews_allowed is not -1 and num_reviews_allowed is less than num_reviews_required' do
      it 'adds an error message to current assignment object'
    end

    context 'when the first if condition is false, num_metareviews_allowed is not -1, and num_metareviews_allowed less than num_metareviews_required' do
      it 'adds an error message to current assignment object'
    end
  end

  describe '#assign_metareviewer_dynamically' do
    it 'returns true when assigning successfully'
  end

  describe '#response_map_to_metareview' do
    it 'does not raise any errors and returns the first review response map'
  end

  describe '#metareview_mappings' do
    it 'returns review mapping'
  end

  describe '#dynamic_reviewer_assignment?' do
    context 'when review_assignment_strategy of current assignment is Auto-Selected' do
      it 'returns true'
    end

    context 'when review_assignment_strategy of current assignment is Instructor-Selected' do
      it 'returns false'
    end
  end

  describe '#scores' do
    context 'when assignment is varying rubric by round assignment' do
      it 'calculates scores in each round of each team in current assignment'
    end

    context 'when assignment is not varying rubric by round assignment' do
      it 'calculates scores of each team in current assignment'
    end
  end

  describe '#path' do
    context 'when both course_id and instructor_id are nil' do
      it 'raises an error'
    end

    context 'when course_id is not nil and course_id is larger than 0' do
      it 'returns path with course directory path'
    end

    context 'when course_id is nil' do
      it 'returns path without course directory path'
    end
  end

  describe '#check_condition' do
    context 'when the next due date is nil' do
      it 'returns false '
    end

    context 'when the next due date is allowed to review submissions' do
      it 'returns true'
    end
  end

  describe '#submission_allowed' do
    it 'returns true when the next topic due date is allowed to submit sth'
  end

  describe '#quiz_allowed' do
    it 'returns false when the next topic due date is not allowed to do quiz'
  end

  describe '#can_review' do
    it "returns false when the next assignment due date is not allowed to review other's work"
  end

  describe '#metareview_allowed' do
    it 'returns true when the next assignment due date is not allowed to do metareview'
  end

  describe '#delete' do
    context 'when there is at least one review response in current assignment' do
      it 'raises an error messge and current assignment cannot be deleted'
    end

    context 'when there is no review response in current assignment and at least one teammate review response in current assignment' do
      it 'raises an error messge and current assignment cannot be deleted'
    end

    context 'when ReviewResponseMap and TeammateReviewResponseMap can be deleted successfully' do
      it 'deletes other corresponding db records and current assignment'
    end
  end

  describe '#is_microtask?' do
    context 'when microtask is not nil' do
      it 'returns microtask status (false by default)'
    end

    context 'when microtask is nil' do
      it 'returns false'
    end
  end

  describe '#add_participant' do
    context 'when user is nil' do
      it 'raises an error'
    end

    context 'when the user is already a participant of current assignment' do
      it 'raises an error'
    end

    context 'when AssignmentParticipant was created successfully' do
      it 'returns true'
    end
  end

  describe '#create_node' do
    it 'will save node'
  end

  describe '#number_of_current_round' do
    context 'when next_due_date is nil' do
      it 'returns 0'
    end

    context 'when next_due_date is not nil' do
      it 'returns the round of next_due_date'
    end
  end

  describe '#current_stage_name' do
    context 'when assignment has staggered deadline' do
      context 'topic_id is nil' do
        it 'returns Unknow'
      end

      context 'topic_id is not nil' do
        it 'returns Unknow'
      end
    end

    context 'when assignment does not have staggered deadline' do
      context "when due date is not equal to 'Finished', due date is not nil and its deadline name is not nil" do
        it 'returns the deadline name of current due date'
      end
    end
  end

  describe '#is_microtask?' do
    it 'checks whether assignment is a micro task'
  end

  describe '#varying_rubrics_by_round?' do
    it 'returns true if the number of 2nd round questionnaire(s) is larger or equal 1'
  end

  describe '#link_for_current_stage' do
    context 'when current assignment has staggered deadline and topic id is nil' do
      it 'returns nil'
    end

    context 'when current assignment does not have staggered deadline' do
      context 'when due date is a TopicDueDate' do
        it 'returns nil'
      end

      context 'when due_date is not nil, not finished and is not a TopicDueDate' do
        it 'returns description url of current due date'
      end
    end
  end

  describe '#stage_deadline' do
    context 'when topic id is nil and current assignment has staggered deadline' do
      it 'returns Unknown'
    end

    context 'when current assignment does not have staggered deadline' do
      context 'when due date is nil' do
        it 'returns nil'
      end

      context 'when due date is not nil and due date is not equal to Finished' do
        it 'returns due date'
      end
    end
  end

  describe '#num_review_rounds' do
    it 'returns max round number in all due dates of current assignment'
  end

  describe '#find_current_stage' do
    context 'when next due date is nil' do
      it 'returns Finished'
    end

    context 'when next due date is nil' do
      it 'returns next due date object'
    end
  end

  describe '#review_questionnaire_id' do
    it 'returns review_questionnaire_id'
  end

  describe 'has correct csv values?' do
    before(:each) do
      create(:assignment)
      create(:assignment_team, name: 'team1')
      @student = create(:student, name: 'student1')
      create(:participant, user: @student)
      create(:questionnaire)
      create(:question)
      create(:review_response_map)
      create(:response)
      @options = {'team_id' => 'true', 'team_name' => 'true',
                  'reviewer' => 'true', 'question' => 'true',
                  'question_id' => 'true', 'comment_id' => 'true',
                  'comments' => 'true', 'score' => 'true'}
    end

    def generated_csv(t_assignment, t_options)
      delimiter = ','
      CSV.generate(col_sep: delimiter) do |csv|
        csv << Assignment.export_headers(t_assignment.id)
        csv << Assignment.export_details_fields(t_options)
        Assignment.export_details(csv, t_assignment.id, t_options)
      end
    end

    it 'checks_if_csv has the correct data' do
      create(:answer, comments: 'Test comment')
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with some options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_some_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with no data' do
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_data_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with data and no options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['team_name'] = 'false'
      @options['reviewer'] = 'false'
      @options['question'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      @options['comments'] = 'false'
      @options['score'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end
  end
end
