describe CollusionCycle do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  #
  # assignment participant ────┐
  #    ∧                       │
  #    │                       v
  #    └───────────────────── current reviewer (ap)
  #

  let(:response) { build(:response, id: 1) }
  let(:response2) { build(:response, id: 2) }
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:team2) { build(:assignment_team, id: 2, name: "team2", assignment: assignment) }
  let(:team3) { build(:assignment_team, id: 3, name: "team3", assignment: assignment) }
  let(:team4) { build(:assignment_team, id: 4, name: "team4", assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, grade: 90) }
  #let(:participant3) { build(:participant, id: 3) }
  #let(:participant4) { build(:participant, id: 4, grade: 95) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map_no_response_team_1) { build(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, assignment: assignment) }
  let(:response_map_no_response_team_2) { build(:review_response_map, id: 2, reviewee_id: team2.id, reviewer_id: participant.id, assignment: assignment) }
  let(:response_map_team_1) { build(:review_response_map, id: 3, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  let(:response_map_team_2) { build(:review_response_map, id: 4, reviewee_id: team2.id, reviewer_id: participant.id, response: [response], assignment: assignment) }
  
  before(:each) do
    allow(participant).to receive(:team).and_return(team)
    allow(participant2).to receive(:team).and_return(team2)
    #allow(participant3).to receive(:team).and_return(team3)
    #allow(participant4).to receive(:team).and_return(team4)
    @cycle = CollusionCycle.new()
  end

  describe '#two_node_cycles' do
    context 'when the reviewers of current reviewer (ap) does not include current assignment participant' do
      it 'skips this reviewer (ap) and returns corresponding collusion cycles' do
        #Sets up variables for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([])
        
        #Tests if current reviewer does not include current assignment participant
        expect(@cycle.two_node_cycles(participant)).to eql([])
      end
    end

    context 'when the reviewers of current reviewer (ap) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by current reviewer (ap)' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles' do
          #Sets up variables for test
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_no_response_team_1])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_no_response_team_1])
          
          #Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.two_node_cycles(participant)).to eql([])
        end
      end

      context 'when current assignment participant was reviewed by current reviewer (ap)' do
        it 'inserts related information into collusion cycles and returns results' do
          #Sets up variables for test
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_no_response_team_2])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1])
          allow(Response).to receive(:where).with(map_id: response_map_team_1).and_return([response])
          allow(response).to receive(:total_score).and_return(participant2.grade)
          
          #Tests if current assignment participant was reviewed by current reviewer and inserted related information into collusion cycles array
          expect(@cycle.two_node_cycles(participant)).to eql([[participant, 90]])
        end
      end

      context 'when current reviewer (ap) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles' do
          #Sets up variables for test
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_no_response_team_2])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant.id).and_return([response_map_no_response_team_2])
          
          #Tests if reviewer was not reviewed by assignment participant
          expect(@cycle.two_node_cycles(participant)).to eql([[participant, 90]])
        end
      end

      context 'when current reviewer (ap) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results' do
          #Sets up variables for test
          participant.grade = 95
          participant2.assignment = assignment
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1])
          allow(Response).to receive(:where).with(any_args).and_return([response])
          allow(response).to receive(:total_score).and_return(participant2.grade)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant.id).and_return([response_map_team_2])
          allow(Response).to receive(:where).with(map_id: response_map_team_2).and_return([response2])
          allow(response2).to receive(:total_score).and_return(participant.grade)
          
          #Tests if reviewer was reviewed by assignment participant and inserted related information into coluusion cycle array
          #expect(@cycle.two_node_cycles(participant)).to eql([[[participant, 90], [participant2, 95]]])
	  #puts @cycle.two_node_cycles(participant)[0][0][1]

          expect((@cycle.two_node_cycles(participant))[0][0]).to eql ([participant, 90.0])
	  expect((@cycle.two_node_cycles(participant))[0][1]).to eql ([participant, 95.0])
        end
      end
    end
  end

  #
  # assignment participant ────┐
  #    ∧                       │
  #    │                       v
  # current reviewee (ap1) <─ current reviewer (ap2)
  #
  describe '#three_node_cycles' do
    context 'when the reviewers of current reviewer (ap2) does not include current assignment participant' do
      it 'skips this reviewer (ap2) and returns corresponding collusion cycles'
      # Write your test here!
    end

    context 'when the reviewers of current reviewer (ap2) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by current reviewee (ap1)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current assignment participant was reviewed by current reviewee (ap1)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewee (ap1) was not reviewed by current reviewer (ap2)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewee (ap1) was reviewed by current reviewer (ap2)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewer (ap2) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewer (ap2) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end
    end
  end

  #
  #             assignment participant ─> current reviewer (ap3)
  #                                ∧       │
  #                                │       v
  # reviewee of current reviewee (ap1) <─ current reviewee (ap2)
  #
  describe '#four_node_cycles' do
    context 'when the reviewers of current reviewer (ap3) does not include current assignment participant' do
      it 'skips this reviewer (ap3) and returns corresponding collusion cycles'
      # Write your test here!
    end

    context 'when the reviewers of current reviewer (ap3) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by the reviewee of current reviewee (ap1)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current assignment participant was reviewed by the reviewee of current reviewee (ap1)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when the reviewee of current reviewee (ap1) was not reviewed by current reviewee (ap2)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when the reviewee of current reviewee (ap1) was reviewed by current reviewee (ap2)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewee (ap2) was not reviewed by current reviewer (ap3)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewee (ap2) was reviewed by current reviewer (ap3)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewer (ap3) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewer (ap3) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end
    end
  end

  describe '#cycle_similarity_score' do
    context 'when collusion cycle has been calculated, verify the similarity score'do
      it 'returns similarity score based on inputted 2 node cycle' do
        c = [[participant, 90], [participant2, 70]]
        expect(@cycle.cycle_similarity_score(c)).to eql(20.0)
      end
      it 'returns similarity score based on inputted 3 node cycle' do
        c = [[participant, 90], [participant2, 60], [participant2, 30]]
        expect(@cycle.cycle_similarity_score(c)).to eql(40.0)
      end
      it 'returns similarity score based on inputted 4 node cycle' do
        c = [[participant, 80], [participant, 40], [participant, 40], [participant, 0]]
        expect(@cycle.cycle_similarity_score(c)).to eql(40.0)
      end
    end
    
  end

  describe '#cycle_deviation_score' do
    context 'when collusion cycle has been calculated, verify the deviation score' do
      it 'returns cycle deviation score based on inputted 2 node cycle' do
	#c = [[participant, 90], [participant2, 70]]
        #expect(@cycle.cycle_deviation_score(c)).to eql(20.0)
      end
      it 'returns cycle deviation score based on inputted 3 node cycle' do
	#c = [[participant, 90], [participant2, 60], [participant2, 30]]
        #expect(@cycle.cycle_deviation_score(c)).to eql(40.0)
      end
      it 'returns cycle deviation score based on inputted 4 node cycle' do
	#c = [[participant, 80], [participant, 40], [participant, 40], [participant, 0]]
        #expect(@cycle.cycle_deviation_score(c)).to eql(40.0)
      end
    end
    # Write your test here!
  end
end
