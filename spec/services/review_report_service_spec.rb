describe ReviewReportService do
  # Create a basic assignment without setting num_review_rounds directly
  let(:assignment) { create(:assignment) }
  let(:service) { described_class.new(assignment) }

  describe '#update_review_round_counters' do
    let(:reviewer) { create(:participant) }
    let(:team) { create(:assignment_team, assignment: assignment) }
    let(:response_map) { create(:review_response_map, reviewer: reviewer, reviewee: team) }
    
    before do
      allow(assignment).to receive(:num_review_rounds).and_return(2)
      service.send(:initialize_review_round_counters, assignment)
    end

    context 'when responses exist for a round' do
      before do
        # Create a response for round 1
        response = create(:response, map_id: response_map.id, round: 1)
        # Stub Response.where to return our test response
        allow(Response).to receive(:where).with(map_id: response_map.id).and_return([response])
      end

      it 'increments the counter for that round' do
        service.send(:update_review_round_counters, response_map, assignment)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_1"]).to eq(1)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_2"]).to eq(0)
      end
    end

    context 'when responses exist for multiple rounds' do
      before do
        # Create responses for round 1 and 2
        response1 = create(:response, map_id: response_map.id, round: 1)
        response2 = create(:response, map_id: response_map.id, round: 2)
        # Stub Response.where to return our test responses
        allow(Response).to receive(:where).with(map_id: response_map.id).and_return([response1, response2])
      end

      it 'increments counters for all rounds with responses' do
        service.send(:update_review_round_counters, response_map, assignment)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_1"]).to eq(1)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_2"]).to eq(1)
      end
    end

    context 'when no responses exist for a round' do
      before do
        # Stub Response.where to return an empty array
        allow(Response).to receive(:where).with(map_id: response_map.id).and_return([])
      end
      
      it 'does not increment the counter for that round' do
        service.send(:update_review_round_counters, response_map, assignment)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_1"]).to eq(0)
        expect(service.instance_variable_get(:@review_round_counters)["review_in_round_2"]).to eq(0)
      end
    end
  end

  describe '#process_response_maps' do
    let(:reviewer) { create(:participant) }
    let(:team) { create(:assignment_team, assignment: assignment) }
    let(:response_map_with_team) { create(:review_response_map, reviewer: reviewer, reviewee: team) }
    let(:response_map_without_team) { create(:review_response_map, reviewer: reviewer, reviewee_id: 9999) }
    
    before do
      allow(assignment).to receive(:num_review_rounds).and_return(2)
      service.send(:initialize_review_round_counters, assignment)
      # Stub the update_review_round_counters method to focus on process_response_maps functionality
      allow(service).to receive(:update_review_round_counters)
    end

    it 'increments rspan when Team exists for reviewee_id' do
      # Ensure Team.exists? returns true for our team
      allow(Team).to receive(:exists?).with(id: team.id).and_return(true)
      
      result = service.send(:process_response_maps, [response_map_with_team], 0, assignment)
      expect(result[1]).to eq(1) # rspan incremented
    end

    it 'does not increment rspan when Team does not exist for reviewee_id' do
      # Ensure Team.exists? returns false for non-existent team id
      allow(Team).to receive(:exists?).with(id: 9999).and_return(false)
      
      result = service.send(:process_response_maps, [response_map_without_team], 0, assignment)
      expect(result[1]).to eq(0) # rspan unchanged
    end

    it 'calls update_review_round_counters for each response map' do
      expect(service).to receive(:update_review_round_counters).with(response_map_with_team, assignment)
      service.send(:process_response_maps, [response_map_with_team], 0, assignment)
    end

    it 'returns response maps, rspan, and review_round_counters' do
      result = service.send(:process_response_maps, [response_map_with_team], 0, assignment)
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      expect(result[0]).to eq([response_map_with_team])  # response_maps
      expect(result[1]).to be_a(Integer)                # rspan
      expect(result[2]).to be_a(Hash)                   # review_round_counters
      expect(result[2]).to include("review_in_round_1", "review_in_round_2")
    end
  end

  describe '#fetch_response_maps' do
    let(:reviewer) { create(:participant) }
    let(:team) { create(:assignment_team, assignment: assignment) }
    let(:response_map) { create(:review_response_map, reviewed_object_id: assignment.id, reviewer_id: reviewer.id, type: 'ReviewResponseMap') }
    
    before do
      response_map # Create the response map
      allow(assignment).to receive(:num_review_rounds).and_return(2)
    end

    it 'fetches response maps based on parameters' do
      # The actual implementation calls ResponseMap.where
      # Let's check that it returns our response map when parameters match
      maps = service.send(:fetch_response_maps, assignment.id, reviewer.id, 'ReviewResponseMap')
      expect(maps).to include(response_map)
    end

    it 'returns empty array if no maps match' do
      # When no maps match the criteria, it should return an empty array
      maps = service.send(:fetch_response_maps, 9999, reviewer.id, 'ReviewResponseMap')
      expect(maps).to be_empty
    end
  end

  describe '#get_data_for_review_report' do
    let(:reviewer) { create(:participant) }
    let(:team) { create(:assignment_team, assignment: assignment) }
    let(:response_maps) { [create(:review_response_map, reviewer: reviewer, reviewee: team)] }
    
    before do
      # We need to stub the method calls within get_data_for_review_report
      allow(service).to receive(:initialize_review_round_counters)
      allow(service).to receive(:fetch_response_maps).and_return(response_maps)
      allow(service).to receive(:process_response_maps).and_return([response_maps, 1, {"review_in_round_1" => 1, "review_in_round_2" => 0}])
    end

    it 'calls initialize_review_round_counters with the assignment' do
      expect(service).to receive(:initialize_review_round_counters).with(assignment)
      service.get_data_for_review_report(assignment.id, reviewer.id, 'ReviewResponseMap', assignment)
    end

    it 'calls fetch_response_maps with the correct parameters' do
      expect(service).to receive(:fetch_response_maps).with(assignment.id, reviewer.id, 'ReviewResponseMap')
      service.get_data_for_review_report(assignment.id, reviewer.id, 'ReviewResponseMap', assignment)
    end

    it 'calls process_response_maps with the response maps, rspan, and assignment' do
      expect(service).to receive(:process_response_maps).with(response_maps, 0, assignment)
      service.get_data_for_review_report(assignment.id, reviewer.id, 'ReviewResponseMap', assignment)
    end

    it 'returns the processed data from process_response_maps' do
      result = service.get_data_for_review_report(assignment.id, reviewer.id, 'ReviewResponseMap', assignment)
      expect(result).to eq([response_maps, 1, {"review_in_round_1" => 1, "review_in_round_2" => 0}])
    end
  end
  
  describe '#initialize' do
    it 'sets the assignment instance variable' do
      expect(service.assignment).to eq(assignment)
    end
  end

  describe '#initialize_review_round_counters' do
    before do
      # Ensure the assignment returns 2 for num_review_rounds
      allow(assignment).to receive(:num_review_rounds).and_return(2)
    end
  
    it 'initializes counters for each review round' do
      service.send(:initialize_review_round_counters, assignment)
      expect(service.instance_variable_get(:@review_round_counters)).to eq(
        {"review_in_round_1" => 0, "review_in_round_2" => 0}
      )
    end
  
    it 'handles assignments with different number of rounds' do
      # Use a different double for this test
      assignment_with_3_rounds = double('Assignment')
      allow(assignment_with_3_rounds).to receive(:num_review_rounds).and_return(3)
      
      service = described_class.new(assignment_with_3_rounds)
      service.send(:initialize_review_round_counters, assignment_with_3_rounds)
      expect(service.instance_variable_get(:@review_round_counters)).to eq(
        {"review_in_round_1" => 0, "review_in_round_2" => 0, "review_in_round_3" => 0}
      )
    end
  end



 end
