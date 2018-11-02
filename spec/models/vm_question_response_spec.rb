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
    let(:rq) { build(:questionnaire) }
    # let(:afq) { build(:afq, )}
    let(:aq) { build(:assignment_questionnaire) }
    let(:asmt) { build(:assignment) }
    let(:rsp) { VmQuestionResponse.new(rq, asmt, 7) }
    let(:q0) { build(:question) }
    

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
      let(:teem) { create(:assignment_team) }
      let(:ppnt) { create(:participant) }


      it 'adds reviews from a team' do
        rsp.add_reviews(ppnt, teem, true)
        expect(rsp.list_of_reviewers.size).to eq(1)
      end

      it 'displays the members of the team' do
        rsp.display_team_members
      end


    end

  end

end
