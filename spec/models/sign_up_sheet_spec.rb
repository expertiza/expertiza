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

  end
end