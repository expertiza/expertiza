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

    # it 'will return a SignUpSheet when the topic already has deadlines' do
    #   assignment = double(Assignment)
    #   allow(assignment).to receive(:get_review_rounds) { 1 }
    #   allow(Assignment).to receive(:find) { assignment }
    #
    #   topic1 = SignUpTopic.new
    #   topic1.id = 'id'
    #   topic1.topic_identifier = 'topic_identifier'
    #   topic1.topic_name = 'topic_name'
    #   allow(SignUpTopic).to receive(:where) { [topic1] }
    #
    #   topicDeadline = TopicDeadline.new
    #   topicDeadline.due_at = DateTime.new(2000, 1, 1)
    #   allow(TopicDeadline).to receive(:where) { topicDeadline }
    #   allow(topicDeadline).to receive(:first) { topicDeadline }
    #
    #   deadlineType = double(DeadlineType)
    #   allow(DeadlineType).to receive(:find_by_name) { deadlineType }
    #   allow(deadlineType).to receive(:id) { nil }
    #
    #   expect(SignUpSheet.add_signup_topic(2)).to eql({0 => {"id" => 0, "topic_identifier" => "topic_identifier", "topic_name" => "topic_name", "submission_1" => "2000-01-01 00:00:00", "review_1" => "2000-01-01 00:00:00", "submission_2" => "2000-01-01 00:00:00"}})
    # end

  end
end

describe '.confirm_topic' do
  it "create SignedUpTeam" do
    allow(SignUpTopic).to receive(:slotAvailable?) { true }
    expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(false)
  end

  it "sign_up.is_waitlisted is equal to true" do
    allow(SignUpTopic).to receive(:slotAvailable?) { false }
    expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(false)
  end

  it "returns false if user_signup_topic.is_waitlisted == false" do
    user_signup = SignedUpTeam.new
    user_signup.is_waitlisted = false
    allow(SignUpSheet).to receive(:otherConfirmedTopicforUser) { [user_signup] }
    expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(false)

  end
  it "sets sign_up.is_waitlisted = true if slotAvailable is false" do
    allow(SignUpTopic).to receive(:slotAvailable?) { false }
    user_signup = SignedUpTeam.new
    user_signup.is_waitlisted = true
    allow(SignUpSheet).to receive(:otherConfirmedTopicforUser) { [user_signup] }
    expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(nil)
  end


  it "returns true for SignUpSheet.confirmTopic " do
    allow(SignUpTopic).to receive(:slotAvailable?) { true }
    user_signup = SignedUpTeam.new
    user_signup.is_waitlisted = true
    allow(SignUpSheet).to receive(:update_attribute) { [user_signup] }
    allow(SignedUpTeam).to receive(:where) { user_signup }
    allow(user_signup).to receive(:first) { user_signup }
    allow(user_signup).to receive(:update_attribute)
    allow(SignUpSheet).to receive(:otherConfirmedTopicforUser) { [user_signup] }
    expect(SignUpSheet.confirmTopic nil, nil, nil, nil).to eql(true)
  end


end