describe ReputationWebServiceController do


  describe '#calculate' do
    # xit 'should calculate peer review grades' do
    #   has_topic = false
    #   raw_data_array = []
    #   #review_responses = controller.get_review_responses(45, 0)
    #   review_responses = controller.get_review_responses(55, 0)
    #   #review_responses << review_response
    #   raw_data_array = controller.calculate_peer_review_grades(has_topic, review_responses, 0)
    #   expect(raw_data_array).to be_an_instance_of(Array)
    #   expect(raw_data_array).to_not eq(nil)
    # end

    it 'should query database and return review responses' do
      result = controller.get_review_responses(55, 0)
      expect(result).to_not eq(nil)
    end

    it 'should calculate quiz scores and return them as an array' do
      result = controller.calculate_quiz_scores(52,0)
      expect(result).to be_an_instance_of(Array)
      expect(result).to_not eq(nil)
    end
  end
end
