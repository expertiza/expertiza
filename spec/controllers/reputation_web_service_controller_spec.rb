describe ReputationWebServiceController do
  let(:response) { build(:response) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response]) }
  let(:review_response_map) { build(:review_response_map, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:topic) { build(:topic, id: 1, topic_name: "New Topic") }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1) }
  let(:question) { double('Question') }

  describe '#calculate review grades and quiz scores' do
    it 'should calculate peer review grades' do
      has_topic = !SignUpTopic.where(41).empty?
      raw_data_array = controller.fetch_peer_reviews(41, 1, has_topic, 0)
      expect(raw_data_array).to be_an_instance_of(Array)
      expect(raw_data_array).should_not be(nil)
    end

    it 'should calculate quiz scores and return an array' do
      result = controller.fetch_quiz_scores(52,0)
      expect(result).to be_an_instance_of(Array)
      expect(result).to_not eq(nil)
    end
  end
end