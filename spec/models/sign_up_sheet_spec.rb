describe SignUpSheet do
  describe '.add_signup_topic' do
    it 'will return an empty Hash when there are no topics' do
      assignment = double('Assignment')
      allow(assignment).to receive(:num_review_rounds) { nil }
      allow(Assignment).to receive(:find) { assignment }

      allow(SignUpTopic).to receive(:where) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eq({})
    end

    it 'will return a SignUpSheet with one topic and no due dates' do
      assignment = double('Assignment')
      allow(assignment).to receive(:num_review_rounds) { 0 }
      allow(Assignment).to receive(:find) { assignment }

      topic1 = SignUpTopic.new
      topic1.id = 'id'
      topic1.topic_identifier = 'topic_identifier'
      topic1.topic_name = 'topic_name'
      allow(SignUpTopic).to receive(:where) { [topic1] }

      assignment_due_date = double('AssignmentDueDate')

      allow(AssignmentDueDate).to receive(:where) { assignment_due_date }
      allow(AssignmentDueDate).to receive(:first) { nil }

      deadlineType = double('DeadlineType')
      allow(DeadlineType).to receive(:find_by) { deadlineType }
      allow(deadlineType).to receive(:id) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eq(0 => { 'id' => 0, 'topic_identifier' => 'topic_identifier', 'topic_name' => 'topic_name', 'submission_1' => nil })
    end

    it 'will return a SignUpSheet when the topic already has deadlines' do
      skip('skip test on staggered deadline temporarily')
      assignment = double(Assignment)
      allow(assignment).to receive(:num_review_rounds) { 1 }
      allow(Assignment).to receive(:find) { assignment }

      topic1 = SignUpTopic.new
      topic1.id = 'id'
      topic1.topic_identifier = 'topic_identifier'
      topic1.topic_name = 'topic_name'
      allow(SignUpTopic).to receive(:where) { [topic1] }

      assignment_due_date = AssignmentDueDate.new
      assignment_due_date.due_at = DateTime.new(2000, 1, 1)
      allow(AssignmentDueDate).to receive(:where) { assignment_due_date }
      allow(AssignmentDueDate).to receive(:first) { assignment_due_date }

      deadlineType = double(DeadlineType)
      allow(DeadlineType).to receive(:find_by) { deadlineType }
      allow(deadlineType).to receive(:id) { nil }
      expect(SignUpSheet.add_signup_topic(2)).to eq(0 => { 'id' => 0, 'topic_identifier' => 'topic_identifier', 'topic_name' => 'topic_name', 'submission_1' => '2000-01-01 00:00:00', 'review_1' => '2000-01-01 00:00:00', 'submission_2' => '2000-01-01 00:00:00' })
    end
  end
end

describe '.import' do
  it 'raises error if import column equal to 1'

  it 'signs up team for assignment with info from import file'
end
