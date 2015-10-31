require 'rails_helper'

describe SignUpSheet do

  describe '.add_signup_topic' do

    it 'will return an empty Hash when there are no topics' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { nil }
      allow(Assignment).to receive(:find) { assignment }

      allow(SignUpTopic).to receive(:where) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({})
    end

    it 'will return a SignUpSheet with one topic and no due dates' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { 0 }
      allow(Assignment).to receive(:find) { assignment }

      topic1 = SignUpTopic.new
      topic1.id = 'id'
      topic1.topic_identifier = 'topic_identifier'
      topic1.topic_name = 'topic_name'
      allow(SignUpTopic).to receive(:where) { [topic1] }

      topicDeadline = double(TopicDeadline)
      allow(TopicDeadline).to receive(:where) { topicDeadline }
      allow(topicDeadline).to receive(:first) { nil }

      deadlineType = double(DeadlineType)
      allow(DeadlineType).to receive(:find_by_name) { deadlineType }
      allow(deadlineType).to receive(:id) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => nil}})
    end

    it 'will return a SignUpSheet when the topic already has deadlines' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { 1 }
      allow(Assignment).to receive(:find) { assignment }

      topic1 = SignUpTopic.new
      topic1.id = 'id'
      topic1.topic_identifier = 'topic_identifier'
      topic1.topic_name = 'topic_name'
      allow(SignUpTopic).to receive(:where) { [topic1] }

      topicDeadline = TopicDeadline.new
      topicDeadline.due_at = DateTime.new(2000, 1, 1)
      allow(TopicDeadline).to receive(:where) { topicDeadline }
      allow(topicDeadline).to receive(:first) { topicDeadline }

      deadlineType = double(DeadlineType)
      allow(DeadlineType).to receive(:find_by_name) { deadlineType }
      allow(deadlineType).to receive(:id) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => "2000-01-01 00:00:00", "review_1" => "2000-01-01 00:00:00", "submission_2" => "2000-01-01 00:00:00"}})
    end

    it 'will copy deadlines from assignments for new topics' do
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { 1 }
      allow(Assignment).to receive(:find) { assignment }

      topic1 = SignUpTopic.new
      topic1.id = 'id'
      topic1.topic_identifier = 'topic_identifier'
      topic1.topic_name = 'topic_name'
      allow(SignUpTopic).to receive(:where) { [topic1] }

      topicDeadline = TopicDeadline.new
      topicDeadline.due_at = DateTime.new(2000, 1, 1)
      allow(TopicDeadline).to receive(:where) { topicDeadline }
      allow(topicDeadline).to receive(:first).and_return(nil, nil, topicDeadline, topicDeadline)

      deadlineType = double(DeadlineType)
      allow(DeadlineType).to receive(:find_by_name) { deadlineType }
      allow(deadlineType).to receive(:id) { nil }

      allow(DueDate).to receive(:where) { [nil] }
      allow(DueDate).to receive(:assign_topic_deadline) { nil }

      expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => "2000-01-01 00:00:00", "review_1" => "2000-01-01 00:00:00", "submission_2" => "2000-01-01 00:00:00"}})
    end

  end
  require 'rails_helper'

  describe SignUpSheet do

    describe '.add_signup_topic' do

      it 'will return an empty Hash when there are no topics' do
        assignment = double(Assignment)
        allow(assignment).to receive(:get_review_rounds) { nil }
        allow(Assignment).to receive(:find) { assignment }

        allow(SignUpTopic).to receive(:where) { nil }

        expect(SignUpSheet.add_signup_topic(2)).to eql({})
      end

      it 'will return a SignUpSheet with one topic and no due dates' do
        assignment = double(Assignment)
        allow(assignment).to receive(:get_review_rounds) { 0 }
        allow(Assignment).to receive(:find) { assignment }

        topic1 = SignUpTopic.new
        topic1.id = 'id'
        topic1.topic_identifier = 'topic_identifier'
        topic1.topic_name = 'topic_name'
        allow(SignUpTopic).to receive(:where) { [topic1] }

        topicDeadline = double(TopicDeadline)
        allow(TopicDeadline).to receive(:where) { topicDeadline }
        allow(topicDeadline).to receive(:first) { nil }

        deadlineType = double(DeadlineType)
        allow(DeadlineType).to receive(:find_by_name) { deadlineType }
        allow(deadlineType).to receive(:id) { nil }

        expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => nil}})
      end

      it 'will return a SignUpSheet when the topic already has deadlines' do
        assignment = double(Assignment)
        allow(assignment).to receive(:get_review_rounds) { 1 }
        allow(Assignment).to receive(:find) { assignment }

        topic1 = SignUpTopic.new
        topic1.id = 'id'
        topic1.topic_identifier = 'topic_identifier'
        topic1.topic_name = 'topic_name'
        allow(SignUpTopic).to receive(:where) { [topic1] }

        topicDeadline = TopicDeadline.new
        topicDeadline.due_at = DateTime.new(2000, 1, 1)
        allow(TopicDeadline).to receive(:where) { topicDeadline }
        allow(topicDeadline).to receive(:first) { topicDeadline }

        deadlineType = double(DeadlineType)
        allow(DeadlineType).to receive(:find_by_name) { deadlineType }
        allow(deadlineType).to receive(:id) { nil }

        expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => "2000-01-01 00:00:00", "review_1" => "2000-01-01 00:00:00", "submission_2" => "2000-01-01 00:00:00"}})
      end

      it 'will copy deadlines from assignments for new topics' do
        assignment = double(Assignment)
        allow(assignment).to receive(:get_review_rounds) { 1 }
        allow(Assignment).to receive(:find) { assignment }

        topic1 = SignUpTopic.new
        topic1.id = 'id'
        topic1.topic_identifier = 'topic_identifier'
        topic1.topic_name = 'topic_name'
        allow(SignUpTopic).to receive(:where) { [topic1] }

        topicDeadline = TopicDeadline.new
        topicDeadline.due_at = DateTime.new(2000, 1, 1)
        allow(TopicDeadline).to receive(:where) { topicDeadline }
        allow(topicDeadline).to receive(:first).and_return(nil, nil, topicDeadline, topicDeadline)

        deadlineType = double(DeadlineType)
        allow(DeadlineType).to receive(:find_by_name) { deadlineType }
        allow(deadlineType).to receive(:id) { nil }

        allow(DueDate).to receive(:where) { [nil] }
        allow(DueDate).to receive(:assign_topic_deadline) { nil }

        expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => "2000-01-01 00:00:00", "review_1" => "2000-01-01 00:00:00", "submission_2" => "2000-01-01 00:00:00"}})
      end

    end
  end

  describe '.confirm_topic' do
    it "allow user to sign up" do
      allow(SignUpTopic).to receive(:slotAvailable?) { true }
      expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(false)
    end

    it "no topic" do
      allow(SignUpTopic).to receive(:slotAvailable?) { false }
      expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(false)
    end
  end

end