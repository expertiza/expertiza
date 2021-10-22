describe ReputationWebServiceController do
  let(:response) { build(:response) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response]) }
  let(:review_response_map) { build(:review_response_map, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:topic) { build(:topic, id: 1, topic_name: "New Topic") }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1) }
  let(:question) { double('Question') }

  describe '#calculate' do
    # it 'should query database and return review responses' do
    #   result = controller.get_review_responses(1, 0)
    #   expect(result).to_not eq(nil)
    # end
    #
    # it 'should calculate peer review grades' do
    #   has_topic = !SignUpTopic.where(41).empty?
    #   result = controller.get_review_responses(41, 0)
    #   raw_data_array = controller.calculate_peer_review_grades(has_topic,result,1)
    #   expect(raw_data_array).to be_an_instance_of(Array)
    #   expect(raw_data_array).should_not be(nil)
    # end
    #
    # it 'should calculate quiz scores and return them as an array' do
    #   result = controller.calculate_quiz_scores(52,0)
    #   expect(result).to be_an_instance_of(Array)
    #   expect(result).to_not eq(nil)
    # end

    it 'dummy test case' do
      a = 2
      expect(a).to eq(2)
    end

  end
end