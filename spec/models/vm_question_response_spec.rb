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
    let(:q0) { create(:question) }
    

    it 'has a round value of the questionnaire given' do
      expect(rsp.round).to eq(7)
    end

    context 'when given a list of valid questions' do
      it 'adds valid questions' do
        qs = Array.new(1) { q0 }
        expect(rsp.list_of_rows.size).to eq(0)
        rsp.add_questions qs
        expect(rsp.list_of_rows.size).to eq(1)
      end
    end
    
    context 'when given a participant, team, and vary' do
      let(:teem) { create(:team) }
      let(:ppnt) { create(:participant) }

      it 'displays the members of the team' do
        rsp.add_team_members(teem)
        rsp.display_team_members
      end


    end

  end

end
