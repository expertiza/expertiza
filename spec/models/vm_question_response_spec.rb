describe VmQuestionResponse do

  context 'when invalid questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:rsp) { VmQuestionResponse.new(rq, asmt) }
      it 'has no round value given a generic questionnaire' do
        # expect(rsp.round).to be_nil
        # expect response from assignment?
        # expect(asmt).to exist?
      end
  end

  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:rsp) { VmQuestionResponse.new(rq, asmt, 7) }
    it 'has a round value of the questionnaire given' do
      expect(rsp.round).to eq(7)
    end

    it 'adds a question that is not a QuestionnaireHeader' do
      # response.add_questions 'q1'
    end  

    it 'displays the members of the team' do
      rsp.display_team_members
    end
  end

end
