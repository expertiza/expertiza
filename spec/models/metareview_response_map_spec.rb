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
  let(:participant2) { build(:participant, id: 3, parent_id: 3, user: student2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: review_response_map) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: review_response_map, is_submitted: true) }
  let(:response3) { build(:response) }
  let(:metareview_response_map) { build(:meta_review_response_map, review_mapping: review_response_map) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, name: 'name1', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student2) { build(:student, id: 3, name: 'name2', fullname: 'no one', email: 'expertiza@mailinator.com') }
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

      describe '.import' do
        let(:assignment_team) { build(:assignment_team) }
        let(:student) { build(:student, id: 2) }
        let(:metareviewer) { build(:student, id: 3) }
        let(:assignment_participant) { build(:participant) }
        let(:other_assignment_participant) { build(:participant) }
        let(:review_response_map) { build(:review_response_map, assignment: nil, reviewer: nil, reviewee: nil) }
        
        context 'record does not contain required items' do
          it 'should raise ArgumentError' do
            row = { reviewee: 'person', reviewer: 'person' }
            expect { MetareviewResponseMap.import(row, nil, 1) }.to raise_error(ArgumentError, 'Record does not contain required items.')
          end
        end
    
        context 'record contains required items' do
          let(:row) do
            { team_name: 'person1', reviewer: 'person2', metareviewers: 'rev1' }
          end
          let(:id) do
            1
          end
    
          context 'reviewee is not found' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, 'Reviewee team, ' + row[:team_name] + ', was not found.')
            end
          end
    
          context 'reviewer is not found' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, "Reviewer #{row[:reviewer]} not found.")
            end
          end
    
          context 'reviewer does not participate in assignment' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
              allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
              allow(assignment_participant).to receive(:first).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, "Reviewer,  #{row[:reviewer]}, for reviewee team, #{assignment_team.name}, was not found.")
            end
          end
    
          context 'metareviewer not found' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
              allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
              allow(assignment_participant).to receive(:first).and_return(assignment_participant)
              allow(User).to receive(:find_by_name).with(row[:metareviewers]).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, "Metareviewer #{row[:metareviewers]} not found.")
            end
          end
    
          context 'metareviewer does not participate in assignment' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
              allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
              allow(assignment_participant).to receive(:first).and_return(assignment_participant)
              allow(User).to receive(:find_by_name).with(row[:metareviewers]).and_return(metareviewer)
              allow(AssignmentParticipant).to receive(:where).with(user_id: metareviewer.id, parent_id: id).and_return(other_assignment_participant)
              allow(other_assignment_participant).to receive(:first).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, "Metareviewer,  #{row[:metareviewers]}, for reviewee, #{assignment_team.name}, and reviewer, #{row[:reviewer]}, was not found.")
            end
          end
    
          context 'no review mapping between the reviewer and reviewee' do
            it 'raises ImportError' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
              allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
              allow(assignment_participant).to receive(:first).and_return(assignment_participant)
              allow(User).to receive(:find_by_name).with(row[:metareviewers]).and_return(metareviewer)
              allow(AssignmentParticipant).to receive(:where).with(user_id: metareviewer.id, parent_id: id).and_return(other_assignment_participant)
              allow(other_assignment_participant).to receive(:first).and_return(other_assignment_participant)
              allow(ReviewResponseMap).to receive(:where).with(reviewee_id: assignment_team.id, reviewer_id: assignment_participant.id).and_return(review_response_map)
              allow(review_response_map).to receive(:first).and_return(nil)
              expect { MetareviewResponseMap.import(row, nil, id) }.to raise_error(ImportError, "No review mapping was found for reviewee team, #{assignment_team.name}, and reviewer, #{row[:reviewer]}.")
            end
          end
    
          context 'input data has proper relationships' do
            it 'successfully makes a MetareviewResponseMap' do
              allow(AssignmentTeam).to receive(:where).with(name: row[:team_name], parent_id: id).and_return(assignment_team)
              allow(assignment_team).to receive(:first).and_return(assignment_team)
              allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
              allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
              allow(assignment_participant).to receive(:first).and_return(assignment_participant)
              allow(User).to receive(:find_by_name).with(row[:metareviewers]).and_return(metareviewer)
              allow(AssignmentParticipant).to receive(:where).with(user_id: metareviewer.id, parent_id: id).and_return(other_assignment_participant)
              allow(other_assignment_participant).to receive(:first).and_return(other_assignment_participant)
              allow(ReviewResponseMap).to receive(:where).with(reviewee_id: assignment_team.id, reviewer_id: assignment_participant.id).and_return(review_response_map)
              allow(review_response_map).to receive(:first).and_return(review_response_map)
              allow(MetareviewResponseMap).to receive(:where).with(any_args).and_return([])
              expect(MetareviewResponseMap).to receive(:create).with(any_args)
              MetareviewResponseMap.import(row, nil, id)
            end
          end
        end
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
