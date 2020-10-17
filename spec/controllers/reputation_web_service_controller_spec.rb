describe ReputationWebServiceController do


  describe '#calculate' do
    it 'should calculate peer review grades' do
      has_topic = true
      raw_data_array = []
      result = controller.get_review_responses(41, 0)
      raw_data_array = controller.calculate_peer_review_grades(has_topic,result,1)
      expect(raw_data_array).to be_an_instance_of(Array)
      expect(raw_data_array).should_not be(nil)
    end

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
