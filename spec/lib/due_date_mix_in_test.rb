describe Assignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team], max_team_size: 2) }
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
    build(:assignment_due_date, due_at: '2011-11-11 11:11:11', deadline_name: 'Review',
          description_url: 'https://expertiza.ncsu.edu/', round: 1)
  end
  let(:topic_due_date) { build(:topic_due_date, deadline_name: 'Submission', description_url: 'https://github.com/expertiza/expertiza') }
  let(:deadline_type) { build(:deadline_type, id: 1) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let(:assignment_questionnaire2) { build(:assignment_questionnaire, id: 2, assignment_id: 1, questionnaire_id: 2) }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }

  describe '#submission_allowed' do
    it 'returns true when the next topic due date is allowed to submit sth' do
      #allow(assignment).to receive(:check_condition).with('submission_allowed_id', 123).and_return(true)
      #expect(assignment.submission_allowed(123)).to be true
      assignment_due_date = double('AssignmentDueDate')
      assignment_topic_id = double('AssignmentTopicId')
      allow(SignedUpTeam).to receive(:topic_id).with(1, 1).and_return(assignment_topic_id) # 1,1
      allow(DueDate).to receive(:get_next_due_date).with(1, assignment_topic_id).and_return(assignment_due_date)
      allow(assignment_due_date).to receive(:submission_allowed_id).and_return(1)
      allow(DeadlineRight).to receive(:find).with(1).and_return(double('DeadlineRight', name: 'OK'))
      expect(assignment.submission_allowed(1)).to be true
    end
  end

  describe '#quiz_allowed' do
    it 'returns false when the next topic due date is not allowed to do quiz' do
      assignment_due_date = double('AssignmentDueDate')
      assignment_topic_id = double('AssignmentTopicId')
      allow(SignedUpTeam).to receive(:topic_id).with(1, 1).and_return(assignment_topic_id) # 1,1
      allow(DueDate).to receive(:get_next_due_date).with(1, assignment_topic_id).and_return(assignment_due_date)
      allow(assignment_due_date).to receive(:quiz_allowed_id).and_return(1)
      allow(DeadlineRight).to receive(:find).with(1).and_return(double('DeadlineRight', name: 'OK'))
      expect(assignment.quiz_allowed(1)).to be true
    end
  end

  describe '#metareview_allowed' do
    it 'returns true when the next assignment due date is not allowed to do metareview' do
      assignment_due_date = double('AssignmentDueDate')
      assignment_topic_id = double('AssignmentTopicId')
      allow(SignedUpTeam).to receive(:topic_id).with(1, 1).and_return(assignment_topic_id) # 1,1
      allow(DueDate).to receive(:get_next_due_date).with(1, assignment_topic_id).and_return(assignment_due_date)
      allow(assignment_due_date).to receive(:review_of_review_allowed_id).and_return(1)
      allow(DeadlineRight).to receive(:find).with(1).and_return(double('DeadlineRight', name: 'OK'))
      expect(assignment.metareview_allowed(1)).to be true
    end
  end

  describe '#can_review' do
    it 'returns true when the next assignment due date is not allowed to do metareview' do
      assignment_due_date = double('AssignmentDueDate')
      assignment_topic_id = double('AssignmentTopicId')
      allow(SignedUpTeam).to receive(:topic_id).with(1, 1).and_return(assignment_topic_id) # 1,1
      allow(DueDate).to receive(:get_next_due_date).with(1, assignment_topic_id).and_return(assignment_due_date)
      allow(assignment_due_date).to receive(:review_allowed_id).and_return(1)
      allow(DeadlineRight).to receive(:find).with(1).and_return(double('DeadlineRight', name: 'OK'))
      expect(assignment.can_review(1)).to be true
    end
  end

end
