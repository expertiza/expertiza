describe VmQuestionResponse do

  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:vm_rsp) { VmQuestionResponse.new(rq, asmt, 1) }
    let(:q0) { create(:question) }
    let(:header_q) { QuestionnaireHeader(q0) }
    let(:rvw_rsp_map) { create(:review_response_map) }

    it 'adds_reviews' do
      # expect(ReviewResponseMap).to receive(:get_assessments).with(asm_team)
      
      # ans = double('ans')
      # allow(ans).to receive_messages(:question_id => 1, :answer => 5, )
      # allow(ReviewResponseMap).to receive_messages(:get_assessments) {  }
      # allow(Answer).to receive_messages(:where => )
      # allow(TagPromptDeployment).to receive_messages(:where => )
      # allow(Question).to receive_messages(:find => )
      # allow(VmTagPromptAnswer)

    end
    
    context 'when given a team' do
      # let(:team) { create(:assignment_team) }
      # let(:ppnt) { create(:participant) }

      it 'displays the members of the team' do
        team = double('team')
        ppnt0 = double('ppnt0')
        allow(ppnt0).to receive_messages :fullname => 'Julia'
        ppnt1 = double('ppnt0')
        allow(ppnt1).to receive_messages :fullname => 'Python'
        ppnt2 = double('ppnt0')
        allow(ppnt2).to receive_messages :fullname => 'R'

        team_member_names = [ppnt0, ppnt1, ppnt2]
        allow(team).to receive_messages(:participants => team_member_names)
        
        out = 'Team members:'
        vm_rsp.add_team_members(team)
        team.participants.each do |participant|
          out = out + " (" + participant.fullname + ") "
        end
        expect(vm_rsp.display_team_members).to eq out
      end


    end

    it 'has the round value of the given questionnaire' do
      expect(vm_rsp.round).to eq 1
    end

    context 'when given a list of valid questions' do
      let(:qs) { qs = Array.new(1) { q0 } }

      it 'can calculate the max score for the questionnaire' do
        vm_rsp.add_questions qs
        expect(vm_rsp.max_score).to eq 5
        expect(vm_rsp.list_of_rows.size).to eq 1
        expect(vm_rsp.max_score_for_questionnaire()).to eq qs.size * rq.max_question_score
      end
    end

  end

end
