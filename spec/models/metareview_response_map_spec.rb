describe MetareviewResponseMap do
  let(:assignment_team) {build(:assignment_team)}
  let(:student) {build(:student, id: 2)}
  let(:metareviewer) {build(:student, id: 3)}
  let(:assignment_participant) {build(:participant)}
  let(:other_assignment_participant) {build(:participant)}
  let(:review_response_map) {build(:review_response_map, assignment: nil, reviewer: nil, reviewee: nil)}

  describe '.import' do
    context 'record does not contain required items' do
      it 'should raise ArgumentError' do
        row = {reviewee: 'person', reviewer: 'person'}
        expect {MetareviewResponseMap.import(row, nil, 1)}.to raise_error(ArgumentError, "Record does not contain required items.")
      end
    end

    context 'record contains required items' do
      let(:row) do
        {reviewee: 'person1', reviewer: 'person2', metareviewers: ['rev1']}
      end
      let(:id) do
        1
      end

      context 'reviewee is not found' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "Reviewee, " + row[:reviewee] + ", was not found.")
        end
      end

      context 'reviewer is not found' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "Reviewer #{row[:reviewer]} not found.")
        end
      end

      context 'reviewer does not participate in assignment' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
          allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
          allow(assignment_participant).to receive(:first).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "Reviewer,  #{row[:reviewer]}, for reviewee, #{assignment_team.name}, was not found.")
        end
      end

      context 'metareviewer not found' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
          allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
          allow(assignment_participant).to receive(:first).and_return(assignment_participant)
          allow(User).to receive(:find_by_name).with(row[:metareviewers].first).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "Metareviewer #{row[:metareviewers].first} not found." )
        end
      end

      context 'metareviewer does not participate in assignment' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
          allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
          allow(assignment_participant).to receive(:first).and_return(assignment_participant)
          allow(User).to receive(:find_by_name).with(row[:metareviewers].first).and_return(metareviewer)
          allow(AssignmentParticipant).to receive(:where).with(user_id: metareviewer.id, parent_id: id).and_return(other_assignment_participant)
          allow(other_assignment_participant).to receive(:first).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "Metareviewer,  #{row[:metareviewers].first}, for reviewee, #{assignment_team.name}, and reviewer, #{row[:reviewer] }, was not found." )
        end
      end

      context 'no review mapping between the reviewer and reviewee' do
        it 'raises ImportError' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
          allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
          allow(assignment_participant).to receive(:first).and_return(assignment_participant)
          allow(User).to receive(:find_by_name).with(row[:metareviewers].first).and_return(metareviewer)
          allow(AssignmentParticipant).to receive(:where).with(user_id: metareviewer.id, parent_id: id).and_return(other_assignment_participant)
          allow(other_assignment_participant).to receive(:first).and_return(other_assignment_participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: assignment_team.id, reviewer_id: assignment_participant.id).and_return(review_response_map)
          allow(review_response_map).to receive(:first).and_return(nil)
          expect {MetareviewResponseMap.import(row, nil, id)}.to raise_error(ImportError, "No review mapping was found for reviewee, #{assignment_team.name}, and reviewer, #{row[:reviewer]}.")
        end
      end

      context 'input data has proper relationships' do
        it 'successfully makes a MetareviewResponseMap' do
          allow(AssignmentTeam).to receive(:where).with(name: row[:reviewee], parent_id: id).and_return(assignment_team)
          allow(assignment_team).to receive(:first).and_return(assignment_team)
          allow(User).to receive(:find_by_name).with(row[:reviewer]).and_return(student)
          allow(AssignmentParticipant).to receive(:where).with(user_id: student.id, parent_id: id).and_return(assignment_participant)
          allow(assignment_participant).to receive(:first).and_return(assignment_participant)
          allow(User).to receive(:find_by_name).with(row[:metareviewers].first).and_return(metareviewer)
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
end