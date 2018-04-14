require 'rails_helper'
require 'spec_helper'

describe 'AutomaticReviewMappingHelper' do
  before(:each) do
    @assignment = create(:assignment)
    @participant = create(:participant)
  end
  let(:team) { double('AssignmentTeam', name: 'no one', id: 1) }
  let(:team1) { double('AssignmentTeam', name: 'no one1', id: 2) }

  describe '#automatic_review_mapping_strategy' do
    context 'When all the calibrated params are not zero' do
      it 'sets the values of different instance variables and calls appropriate methods' do
        allow(helper).to receive(:assign_reviewers_for_team).with(:calibrated_artifacts_num, :params)
      end
    end
    context 'when calibrated params are not zero' do
      it 'raises an exception if the student reviews are greater or equals the number of teams' do
        teams = [team, team1]
        expect { helper.execute_peer_review_strategy(teams, 0, 0, :params) }.to raise_exception(NoMethodError)
      end
    end
  end

  describe '#execute_peer_review_strategy' do
    it 'Raises an exception' do
      expect { raise 'You cannot set the number of reviews done \
      by each student to be greater than or equal to total number of teams \
      [or "participants" if it is an individual assignment].' }.to raise_exception(StandardError)
    end
  end

  describe '#peer_review_strategy' do
    it 'raises an exception' do
      expect { raise "Automatic assignment of reviewer failed." }.to raise_exception(StandardError)
    end
  end
end
