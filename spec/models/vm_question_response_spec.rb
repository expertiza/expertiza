describe VmQuestionResponse do
  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:rsp) { VmQuestionResponse.new(rq, asmt, 1) }
    let(:q0) { create(:question) }
    let(:header_q) { QuestionnaireHeader(q0) }
    let(:rvw_rsp_map) { create(:review_response_map) }


    
    context 'when given a team' do
      let(:team) { create(:assignment_team) }
      let(:ppnt) { create(:participant) }

      it 'displays the members of the team' do
        # ppnt.user.fullname = 'Voldemort'
        # team.add_participant(1, ppnt)
        out = 'Team members:'
        rsp.add_team_members(team)
        rsp.listofteamparticipants.each do |participant|
          out = out + " (" + participant.fullname + ") "
        end
        expect(rsp.display_team_members).to eq out
      end

      
    end

    it 'has the round value of the given questionnaire' do
      expect(rsp.round).to eq 1
    end

    context 'when given a list of valid questions' do
      let(:qs) { qs = Array.new(1) { q0 } }

      it 'can calculate the max score for the questionnaire' do
        rsp.add_questions qs
        expect(rsp.max_score).to eq 5
        expect(rsp.list_of_rows.size).to eq 1
        expect(rsp.max_score_for_questionnaire()).to eq qs.size * rq.max_question_score
      end
    end

  end

end
