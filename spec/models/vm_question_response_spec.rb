describe VmQuestionResponse do
  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:rsp) { VmQuestionResponse.new(rq, asmt, 7) }
    let(:q0) { create(:question) }
    let(:header_q) { QuestionnaireHeader(q0) }
    
    

    it 'has the round value of the given questionnaire' do
      expect(rsp.round).to eq(7)
    end

    context 'when given a list of valid questions' do
      let(:qs) { qs = Array.new(1) { q0 } }

      it 'can calculate the max score for the questionnaire' do
        rsp.add_questions qs
        expect(rsp.max_score).to eq 5
        expect(rsp.list_of_rows.size).to eq(1)
        expect(rsp.max_score_for_questionnaire()).to eq qs.size * rq.max_question_score
      end
    end
    
    context 'when given a participant, team, and vary' do
      let(:team) { create(:assignment_team) }
      let(:ppnt) { create(:participant) }

      it 'displays the members of the team' do
        out = 'Team members:'
        rsp.add_team_members(team)
        rsp.listofteamparticipants.each do |participant|
          out = out + " (" + participant.fullname + ") "
        end
        expect(rsp.display_team_members).to eq out
      end
    end

    context 'and when given answers' do
      let(:ans) { create(:answer) }
      let(:anss) { [ans, ans] }
      it 'adds each row score (answer) to its corresponding row' do

      end    
    end
  end

end
