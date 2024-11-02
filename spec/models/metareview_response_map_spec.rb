describe MetareviewResponseMap do
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team2) { build(:assignment_team, id: 3, name: 'no team') }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student]) }
  let(:team3) { build(:assignment_team, id: 4, name: 'team has name1', assignment: assignment, users: [student1]) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map1) do
    build :review_response_map,
          id: 2,
          assignment: assignment,
          reviewer: participant1,
          reviewee: team1,
          reviewed_object_id: 1,
          response: [response],
          calibrate_to: 0
  end
  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: review_response_map) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: review_response_map, is_submitted: true) }
  let(:response3) { build(:response) }
  let(:metareview_response_map) { build(:meta_review_response_map, review_mapping: review_response_map) }
  let(:student) { build(:student, id: 1, username: 'name', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, username: 'name1', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:student2) { build(:student, id: 3, username: 'name2', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let(:assignment_questionnaire2) { build(:assignment_questionnaire, id: 2, assignment_id: 1, questionnaire_id: 2) }
  let(:questionnaire1) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, type: 'MetareviewQuestionnaire') }
  let(:next_due_date) { build(:assignment_due_date, round: 1) }
  let(:question) { double('Question') }
  let(:review_questionnaire) { build(:questionnaire, id: 1) }
  let(:response3) { build(:response) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response3]) }
  let(:assignment3) { build(:assignment, id: 4, questionnaires: []) }
  let(:participant2) { build(:participant, id: 3, parent_id: 4, user: student2) }
  let(:qmetareview_response_map) { build(:meta_review_response_map, id: 3, review_mapping: review_response_map3, reviewee: participant2) }
  let(:review_response_map3) { build(:review_response_map, id: 3, assignment: assignment3, reviewer: participant, reviewee: team) }
  
  let(:assignment_questionnaire3) { build(:assignment_questionnaire, id: 3, assignment_id: 4, questionnaire: questionnaire2) }
  before(:each) do
    allow(review_response_map).to receive(:response).and_return(response)
    allow(response_map).to receive(:response).and_return(response3)
    allow(response_map).to receive(:id).and_return(1)
  end

  describe '#metareview_response_map' do
    context 'When getting properties of metareview_response_map' do
      it 'finds version numbers' do
        allow(Response).to receive(:find).and_return(response)
        allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
        expect(metareview_response_map.get_all_versions).to eq([])
      end

      it 'finds the contributor of the metareview' do
        allow(Response).to receive(:find).and_return(response)
        allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
        allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
        expect(metareview_response_map.contributor).to eq(team)
      end

      it 'finds the nil questionaire' do
        # questionnaire should return nil correctly if no questionnaire in assignment, rather than garbage result
        participant2.assignment = assignment3
        allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
        expect(qmetareview_response_map.questionnaire).to eq(nil)
      end

      it 'finds title' do
        allow(Response).to receive(:find).and_return(response)
        allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
        expect(metareview_response_map.get_title).to eq('Metareview')
      end

      it 'finds fields' do
        allow(Response).to receive(:find).and_return(response)
        allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
        expect(MetareviewResponseMap.export_fields(nil)).to eq(['contributor', 'reviewed by', 'metareviewed by'])
      end
    end

    context 'When using functionality of metareview_response_map' do
      it '#export' do
        csv = []
        parent_id = 1
        options = nil
        allow(Response).to receive(:find).and_return(response)
        allow(MetareviewResponseMap).to receive(:find_by).and_return(metareview_response_map)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(Assignment).to receive(:metareview_mappings).and_return(metareview_response_map)
        expect(MetareviewResponseMap.export(csv, parent_id, options)).to eq([metareview_response_map])
      end

      it '#import' do
        row_hash = { reviewee: 'name', metareviewers: ['name1'] }
        session = nil
        assignment_id = 1
        # when reviewee user = nil
        allow(User).to receive(:find_by).and_return(nil)
        expect { MetareviewResponseMap.import(row_hash, session, 1) }.to raise_error(ArgumentError, 'Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>')
        # when reviewee user doesn't exist
        row_hash = { reviewee: 'name', metareviewers: ['name1'], reviewer: 'name1' }
        allow(User).to receive(:find_by).with(username: 'name1').and_return(student)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
        expect { MetareviewResponseMap.import(row_hash, session, 1) }.to raise_error(ImportError, 'Contributor, ' + row_hash[:reviewee].to_s + ', was not found.')
        # when a metareview response map is created
        allow(User).to receive(:find_by).with(username: 'name2').and_return(student2)
        allow(AssignmentParticipant).to receive(:where).with(user_id: 3, parent_id: 1).and_return([participant])
        allow(AssignmentTeam).to receive(:where).with(name: 'name', parent_id: 1).and_return([team])
        allow(AssignmentParticipant).to receive(:where).with(user_id: 1, parent_id: 1).and_return([student])
        row_hash = { reviewee: 'name', metareviewers: ['name1'], reviewer: 'name2' }
        expect { MetareviewResponseMap.import(row_hash, session, 1).to eq(metareview_response_map) }
        ## when reviewer user doesn't exist
        allow(User).to receive(:find_by).with(username: 'name2').and_return(student2)
        allow(AssignmentParticipant).to receive(:where).with(user_id: 3, parent_id: 1).and_return([participant])
        allow(AssignmentTeam).to receive(:where).with(name: 'name', parent_id: 1).and_return([team])
        allow(AssignmentParticipant).to receive(:where).with(user_id: 1, parent_id: 1).and_return(nil)
        row_hash = { reviewee: 'name', metareviewers: ['name1'], reviewer: 'name2' }
        expect { MetareviewResponseMap.import(row_hash, session, 1) }.to raise_error(ImportError, 'Metareviewer,  name1, for contributor, team no name, and reviewee, name2, was not found.')
        # # when a review response map is created
        # allow(User).to receive(:find_by).with(name: "name2").and_return(student2)
        # allow(AssignmentParticipant).to receive(:where).with(user_id: 3, parent_id: 1).and_return([participant])
        # allow(AssignmentTeam).to receive(:where).with(name: "name", parent_id: 1).and_return([team])
        # allow(AssignmentParticipant).to receive(:where).with(user_id: 1, parent_id: 1).and_return([student])
        # allow(ReviewResponseMap).to receive(:find_or_create_by)
        #                                 .with(reviewed_object_id: 1, reviewer_id: 2, reviewee_id: 1, calibrate_to: false)
        #                                 .and_return(nil)
        # expect { MetareviewResponseMap.import(row_hash, session, 1) }.to raise_error(ImportError, "No review mapping was found for contributor, , and reviewee, #{row_hash[:reviewer].to_s}.")
      end

      it '#email' do
        reviewer_id = 1
        allow(Participant).to receive(:find).with(1).and_return(participant)
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
        allow(AssignmentTeam).to receive(:users).and_return(student)
        allow(User).to receive(:find).with(1).and_return(student)
        review_response_map.reviewee_id = 1
        defn = { body: { type: 'Metareview', obj_name: 'Test Assgt', first_name: 'no one', partial_name: 'new_submission' }, to: 'expertiza@mailinator.com' }
        expect { metareview_response_map.email(defn, participant, Assignment.find(Participant.find(reviewer_id).parent_id)) }
          .to change { ActionMailer::Base.deliveries.count }.by 1
      end
    end
  end
end
