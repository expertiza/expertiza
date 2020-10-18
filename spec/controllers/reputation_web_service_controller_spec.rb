describe ReputationWebServiceController do

  describe '#calculate' do
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
