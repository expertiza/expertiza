describe SupplementaryReviewQuestionnairesController do
    let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
    let(:student1) { build(:student, id: 1, name: "student1") }
    let(:student2) { build(:student, id: 2, name: "student2") }
    let(:participant) { build(:participant, id: 1, user: student1, assignment: assignment) }
    let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }
    let(:assignment) { build(:assignment, id: 1) }

    # test the method of create_supplementary_review_questionnaire
    describe '#create_supplementary_review_questionnaire' do
      it 'redirects to questionnaires#edit page after create a new supplementary review questionnaire' do
        session = {user: student1}
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant) 
        allow(participant).to receive(:team).and_return(team)
        allow(Team).to receive(:find).with(1).and_return(team) 
        params = {id: 1}
        get :create_supplementary_review_questionnaire, params, session
        expect(response).to redirect_to("/supplementary_review_questionnaires/#{team.supplementary_review_questionnaire_id}/edit")
    end
  end



end