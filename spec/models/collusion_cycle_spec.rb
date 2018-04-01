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

  let(:response_1_2) { build(:response, id: 1) }
  let(:response_2_1) { build(:response, id: 2) }
  let(:response_2_3) { build(:response, id: 3) }
  let(:response_3_1) { build(:response, id: 4) }
  let(:response_3_4) { build(:response, id: 5) }
  let(:response_4_1) { build(:response, id: 6) }
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:team2) { build(:assignment_team, id: 2, name: "team2", assignment: assignment) }
  let(:team3) { build(:assignment_team, id: 3, name: "team3", assignment: assignment) }
  let(:questionnaire) { build(:questionnaire, id: 1) }
  let(:team4) { build(:assignment_team, id: 4, name: "team4", assignment: assignment) }
  let(:participant) { build(:participant, id: 1, user: student, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }
  let(:participant3) { build(:participant, id: 3, user: student3, assignment: assignment) }
  let(:participant4) { build(:participant, id: 4, user: student4, assignment: assignment) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map_team_1_2) {
    build(:review_response_map,
    id: 1,
    reviewee_id: team.id,
    reviewer_id: participant2.id,
    response: [response_1_2],
    assignment: assignment)
  }
  let(:response_map_team_2_1) {
    build(:review_response_map,
    id: 2,
    reviewee_id: team2.id,
    reviewer_id: participant.id,
    response: [response_2_1],
    assignment: assignment)
  }
  let(:response_map_team_2_3) {
    build(:review_response_map,
    id: 3,
    reviewee_id: team2.id,
    reviewer_id: participant3.id,
    response: [response_2_3],
    assignment: assignment)
  }
  let(:response_map_team_3_1) {
    build(:review_response_map,
    id: 4,
    reviewee_id: team3.id,
    reviewer_id: participant.id,
    response: [response_3_1],
    assignment: assignment)
  }
  let(:response_map_team_3_4) {
    build(:review_response_map,
    id: 5,
    reviewee_id: team3.id,
    reviewer_id: participant4.id,
    response: [response_3_4],
    assignment: assignment)
  }
  let(:response_map_team_4_1) {
    build(:review_response_map,
      id: 6,
      reviewee_id: team4.id,
      reviewer_id: participant.id,
      response: [response_4_1],
      assignment: assignment)
  }
  let(:student) { build(:student, id: 1, name: "Cameron") }
  let(:student2) { build(:student, id: 2, name: "Robert") }
  let(:student3) { build(:student, id: 3, name: "Peter") }
  let(:student4) { build(:student, id: 4, name: "Zhewei") }

  before(:each) do
    allow(participant).to receive(:team).and_return(team)
    allow(participant2).to receive(:team).and_return(team2)
    allow(participant).to receive(:id).and_return(1)
    allow(participant2).to receive(:id).and_return(2)
    allow(participant3).to receive(:id).and_return(3)
    allow(participant4).to receive(:id).and_return(4)
    allow(participant).to receive(:review_score).and_return(90)
    allow(participant2).to receive(:review_score).and_return(70)
    allow(participant3).to receive(:review_score).and_return(99)
    allow(participant4).to receive(:review_score).and_return(100)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
    allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
    allow(AssignmentParticipant).to receive(:find).with(4).and_return(participant4)
    allow(participant3).to receive(:team).and_return(team3)
    allow(participant4).to receive(:team).and_return(team4)
    allow(response_1_2).to receive(:total_score).and_return(90)
    allow(response_2_1).to receive(:total_score).and_return(95)
    allow(response_2_3).to receive(:total_score).and_return(82)
    allow(response_3_1).to receive(:total_score).and_return(97)
    allow(response_3_4).to receive(:total_score).and_return(80)
    allow(response_4_1).to receive(:total_score).and_return(0)
    @cycle = CollusionCycle.new
  end

  describe '#two_node_cycles' do
    context 'when the reviewers of current reviewer (ap) does not include current assignment participant' do
      it 'skips this reviewer (ap) and returns corresponding collusion cycles' do
        # Sets up stubs for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([])

        # Tests if current reviewer does not include current assignment participant
        expect(@cycle.two_node_cycles(participant)).to eq([])
      end
    end

    context 'when the reviewers of current reviewer (ap) includes current assignment participant' do
      # This before each function is used to extract out re-appearing code used in two_node_cycle tests
      # More specifically, it is used to extract out the common code used to
      # create a relationship between two revewing participants
      before(:each) do
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2_1])
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      end

      context 'when current assignment participant was not reviewed by current reviewer (ap)' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)

          # Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.two_node_cycles(participant)).to eq([])
        end
      end

      context 'when current assignment participant was reviewed by current reviewer (ap)' do
        it 'inserts related information into collusion cycles and returns results' do
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1_2])
          allow(Response).to receive(:where).with(map_id: [response_map_team_1_2]).and_return([response_1_2])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant.id).and_return([response_map_team_2_1])
          allow(Response).to receive(:where).with(map_id: [response_map_team_2_1]).and_return([response_2_1])

          # Tests if current assignment participant was reviewed by current reviewer and insert related information into collusion cycles array
          expect(@cycle.two_node_cycles(participant)[0][0]).to eq([participant, 90])
        end
      end

      context 'when current reviewer (ap) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant).and_return(nil)

          # Tests if reviewer was not reviewed by assignment participant
          expect(@cycle.two_node_cycles(participant)).to eq([])
        end
      end

      context 'when current reviewer (ap) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results' do
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1_2])
          allow(Response).to receive(:where).with(map_id: [response_map_team_1_2]).and_return([response_1_2])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant.id).and_return([response_map_team_2_1])
          allow(Response).to receive(:where).with(map_id: [response_map_team_2_1]).and_return([response_2_1])

          # Tests if reviewer was reviewed by assignment participant and inserted related information into coluusion cycle arr
          expect(@cycle.two_node_cycles(participant)).to eq([[[participant, 90], [participant2, 95]]])
        end
      end
    end
  end

  #
  # assignment participant ────┐
  #    ∧                                  │
  #    │                       v
  # current reviewee (ap1) <─ current reviewer (ap2)
  #
  describe '#three_node_cycles' do
    context 'when the reviewers of current reviewer (ap2) does not include current assignment participant' do
      it 'skips this reviewer (ap2) and returns corresponding collusion cycles' do
        # Sets up stubs for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2_3])
        allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team3.id).and_return([])

        # Tests if current reviewer does not include current assignment participant
        expect(@cycle.three_node_cycles(participant)).to eq([])
      end
    end

    context 'when the reviewers of current reviewer (ap2) includes current assignment participant' do
      # This before-each function is used to extract out re-appearing code used in three_node_cycle tests
      # More specifically, it is used to extract out the common code used to
      # create a relationship between three revewing participants.
      before(:each) do
        # Sets up stubs for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2_3])
        allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team3.id).and_return([response_map_team_3_1])
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      end
      context 'when current assignment participant was not reviewed by current reviewee (ap1)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)
          # Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.three_node_cycles(participant)).to eq([])
        end
      end

      context 'when a full, four participant relationship has been constructed' do
        before(:each) do
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1_2])
          allow(Response).to receive(:where).with(map_id: [response_map_team_1_2]).and_return([response_1_2])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant3.id).and_return([response_map_team_2_3])
          allow(Response).to receive(:where).with(map_id: [response_map_team_2_3]).and_return([response_2_3])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team3.id, reviewer_id: participant.id).and_return([response_map_team_3_1])
          allow(Response).to receive(:where).with(map_id: [response_map_team_3_1]).and_return([response_3_1])
        end
        context 'when current assignment participant was reviewed by current reviewee (ap1)' do
          it 'inserts related information into collusion cycles and returns results' do
            # Sets up stubs for test
            # Tests if current assignment participant was reviewed by current reviewer and insert related information into collusion cycles array
            expect(@cycle.three_node_cycles(participant)[0][0]).to eq([participant, 90])
          end
        end

        context 'when current reviewee (ap1) was reviewed by current reviewer (ap2)' do
          it 'inserts related information into collusion cycles and returns results' do
            expect(@cycle.three_node_cycles(participant)).to eq([[[participant, 90], [participant2, 82], [participant3, 97]]])
          end
        end

        context 'when current reviewer (ap2) was reviewed by current assignment participant' do
          it 'inserts related information into collusion cycles and returns results' do
            # Tests if reviewer (ap2) was reviewed by assignment participant and inserted related information into coluusion cycle arr
            expect(@cycle.three_node_cycles(participant)).to eq([[[participant, 90], [participant2, 82], [participant3, 97]]])
          end
        end
      end

      context 'when current reviewer (ap2) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant).and_return(nil)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response_2_3)
          expect(@cycle.three_node_cycles(participant)).to eq([])
        end
      end

      context 'when current reviewee (ap1) was not reviewed by current reviewer (ap2)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant).and_return(response_3_1)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(nil)
          expect(@cycle.three_node_cycles(participant)).to eq([])
        end
      end
    end
  end

  #
  #             assignment participant ─> current reviewer (ap3)
  #                                ∧          │
  #                                │       v
  # reviewee of current reviewee (ap1) <─ current reviewee (ap2)
  #
  describe '#four_node_cycles' do
    context 'when the reviewers of current reviewer (ap3) does not include current assignment participant' do
      it 'skips this reviewer (ap3) and returns corresponding collusion cycles' do
        # Sets up stubs for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2_3])
        allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team3.id).and_return([response_map_team_3_4])
        allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant4)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team4.id).and_return([])

        # Tests if current reviewer does not include current assignment participant
        expect(@cycle.four_node_cycles(participant)).to eq([])
      end
    end

    context 'when the reviewers of current reviewer (ap3) includes current assignment participant' do
      # This before-each function is used to extract out re-appearing code used in four_node_cycle tests
      # More specifically, it is used to extract out the common code used to
      # create a relationship between four revewing participants
      before(:each) do
        # Sets up stubs for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_team_1_2])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_team_2_3])
        allow(AssignmentParticipant).to receive(:find).with(3).and_return(participant3)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team3.id).and_return([response_map_team_3_4])
        allow(AssignmentParticipant).to receive(:find).with(4).and_return(participant4)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team4.id).and_return([response_map_team_4_1])
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      end
      context 'when a full, four participant relationship has been constructed' do
        before(:each) do
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_team_1_2])
          allow(Response).to receive(:where).with(map_id: [response_map_team_1_2]).and_return([response_1_2])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant3.id).and_return([response_map_team_2_3])
          allow(Response).to receive(:where).with(map_id: [response_map_team_2_3]).and_return([response_2_3])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team3.id, reviewer_id: participant4.id).and_return([response_map_team_3_4])
          allow(Response).to receive(:where).with(map_id: [response_map_team_3_4]).and_return([response_3_4])
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team4.id, reviewer_id: participant.id).and_return([response_map_team_4_1])
          allow(Response).to receive(:where).with(map_id: [response_map_team_4_1]).and_return([response_4_1])
        end
        context 'when current assignment participant was reviewed by the reviewee of current reviewee (ap1)' do
          it 'inserts related information into collusion cycles and returns results' do
            # Tests if current assignment participant was reviewed by current
            # reviewer and insert related information into collusion cycles array
            expect(@cycle.four_node_cycles(participant)[0][0]).to eq([participant, 90])
          end
        end

        context 'when the reviewee of current reviewee (ap1) was reviewed by current reviewee (ap2)' do
          it 'inserts related information into collusion cycles and returns results' do
            allow(ReviewResponseMap).to receive(:where).with(any_args).and_return([])
            # Tests if reviewer was not reviewed by assignment participant
            expect(@cycle.four_node_cycles(participant)).to eq([])
          end
        end

        context 'when current reviewee (ap2) was reviewed by current reviewer (ap3)' do
          it 'inserts related information into collusion cycles and returns results' do
            # Tests if reviewer was reviewed by assignment participant and inserted related information into coluusion cycle arr
            expect(@cycle.four_node_cycles(participant)).to eq([[[participant, 90], [participant2, 82], [participant3, 80], [participant4, 0]]])
          end
        end

        context 'when current reviewer (ap3) was reviewed by current assignment participant' do
          it 'inserts related information into collusion cycles and returns results' do
            # Tests if reviewer was reviewed by assignment participant and inserted related information into coluusion cycle arr
            expect(@cycle.four_node_cycles(participant)).to eq([[[participant, 90], [participant2, 82], [participant3, 80], [participant4, 0]]])
          end
        end
      end

      context 'when current assignment participant was not reviewed by the reviewee of current reviewee (ap1)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(nil)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response_2_3)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(response_3_4)
          allow(participant4).to receive(:reviews_by_reviewer).with(participant).and_return(response_4_1)

          # Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.four_node_cycles(participant)).to eq([])
        end
      end

      context 'when the reviewee of current reviewee (ap1) was not reviewed by current reviewee (ap2)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(nil)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(response_3_4)
          allow(participant4).to receive(:reviews_by_reviewer).with(participant).and_return(response_4_1)
          expect(@cycle.four_node_cycles(participant)).to eq([])
        end
      end

      context 'when current reviewee (ap2) was not reviewed by current reviewer (ap3)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response_2_3)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(nil)
          allow(participant4).to receive(:reviews_by_reviewer).with(participant).and_return(response_4_1)

          # Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.four_node_cycles(participant)).to eq([])
        end
      end

      context 'when current reviewer (ap3) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles' do
          allow(participant).to receive(:reviews_by_reviewer).with(participant2).and_return(response_1_2)
          allow(participant2).to receive(:reviews_by_reviewer).with(participant3).and_return(response_2_3)
          allow(participant3).to receive(:reviews_by_reviewer).with(participant4).and_return(response_3_4)
          allow(participant4).to receive(:reviews_by_reviewer).with(participant).and_return(nil)
          # Tests if reviewer was not reviewed by assignment participant
          expect(@cycle.four_node_cycles(participant)).to eq([])
        end
      end
    end
  end

  describe '#cycle_similarity_score' do
    context 'when collusion cycle has been calculated, verify the similarity score' do
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
        c = [[participant, 91], [participant2, 71]]
        expect(@cycle.cycle_deviation_score(c)).to eql(1.0)
      end
      it 'returns cycle deviation score based on inputted 3 node cycle' do
        c = [[participant, 92], [participant2, 72], [participant3, 97]]
        expect(@cycle.cycle_deviation_score(c)).to eql(2.0)
      end
      it 'returns cycle deviation score based on inputted 4 node cycle' do
        c = [[participant, 91], [participant2, 71], [participant3, 100], [participant4, 99]]
        expect(@cycle.cycle_deviation_score(c)).to eql(1.0)
      end
    end
    # Write your test here!
  end
end

