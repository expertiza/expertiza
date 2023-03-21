describe DeadlineHelper do
  before(:each) do
    @deadline_type = create(:deadline_type)
    @deadline_right = create(:deadline_right)
    @topic_due_date = create(:topic_due_date, deadline_type: @deadline_type,
                                              submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
                                              review_of_review_allowed_id: @deadline_right.id)
  end

  describe '#create_topic_deadline' do
    it 'should fail because of invalid due_date' do
      expect { helper.create_topic_deadline(nil, 0, 0) }.to raise_exception(NoMethodError)
    end

    it 'new due_date object created' do
      helper.create_topic_deadline(@topic_due_date, 0, 1)
      expect(TopicDueDate.count).to be == 2
    end

    it 'due_at should be same for 0 offset' do
      helper.create_topic_deadline(@topic_due_date, 0, 10)
      new_due_date = TopicDueDate.find_by(parent_id: 10)
      expect(new_due_date).to be_valid
      expect(new_due_date.due_at.to_s).to be == @topic_due_date.due_at.to_s
    end

    it 'due_at calculated correctly for positive offset' do
      helper.create_topic_deadline(@topic_due_date, 5000, 10)
      new_due_date = TopicDueDate.find_by(parent_id: 10)
      expect(new_due_date).to be_valid
      expect(new_due_date.due_at.to_s).to be == (Time.zone.parse(@topic_due_date.due_at.to_s) + 5000).to_s
    end

    it 'due_at calculated correctly for negative offset' do
      helper.create_topic_deadline(@topic_due_date, -5000, 10)
      new_due_date = TopicDueDate.find_by(parent_id: 10)
      expect(new_due_date).to be_valid
      expect(new_due_date.due_at.to_s).to be == (Time.zone.parse(@topic_due_date.due_at.to_s) - 5000).to_s
    end

    it 'offset converted to integer correctly' do
      helper.create_topic_deadline(@topic_due_date, 5000.15, 10)
      new_due_date = TopicDueDate.find_by(parent_id: 10)
      expect(new_due_date).to be_valid
      expect(new_due_date.due_at.to_s).to be == (Time.zone.parse(@topic_due_date.due_at.to_s) + 5000).to_s
    end
  end

  it 'has a valid factory' do
    factory = build(:topic_due_date)
    expect(factory).to be_valid
  end
end
