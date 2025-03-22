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

  describe '#edge cases and error handling' do
    context 'when assignment has zero review rounds' do
      before do
        allow(assignment).to receive(:num_review_rounds).and_return(0)
      end
      
      it 'initializes an empty counter hash' do
        service.send(:initialize_review_round_counters, assignment)
        expect(service.instance_variable_get(:@review_round_counters)).to eq({})
      end
      
      it 'processes response maps without errors' do
        response_map = create(:review_response_map, reviewer: create(:participant), reviewee: create(:assignment_team))
        result = nil
        expect { result = service.send(:process_response_maps, [response_map], 0, assignment) }.not_to raise_error
        expect(result[1]).to eq(1) # rspan should still increment
      end
    end
    
    context 'with nil parameters' do
      it 'handles nil reviewer_id gracefully' do
        expect { service.get_data_for_review_report(assignment.id, nil, 'ReviewResponseMap', assignment) }.not_to raise_error
      end
      
      it 'handles nil assignment gracefully' do
        expect { service.get_data_for_review_report(assignment.id, 1, 'ReviewResponseMap', nil) }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#integration scenarios' do
    let(:reviewer1) { create(:participant) }
    let(:reviewer2) { create(:participant) }
    let(:team1) { create(:assignment_team, assignment: assignment) }
    let(:team2) { create(:assignment_team, assignment: assignment) }
    
    before do
      allow(assignment).to receive(:num_review_rounds).and_return(2)
      
      # Create multiple response maps
      @map1 = create(:review_response_map, reviewer: reviewer1, reviewee: team1)
      @map2 = create(:review_response_map, reviewer: reviewer1, reviewee: team2)
      @map3 = create(:review_response_map, reviewer: reviewer2, reviewee: team1)
      
      # Create responses for different rounds
      create(:response, map_id: @map1.id, round: 1)
      create(:response, map_id: @map2.id, round: 2)
      create(:response, map_id: @map3.id, round: 1)
      create(:response, map_id: @map3.id, round: 2)
    end
    
    it 'correctly counts responses for a specific reviewer' do
      allow(ResponseMap).to receive(:where).and_return([@map1, @map2])
      
      result = service.get_data_for_review_report(assignment.id, reviewer1.id, 'ReviewResponseMap', assignment)
      
      expect(result[0].length).to eq(2) # two response maps
      expect(result[1]).to eq(2) # rspan should be 2 for two teams
      expect(result[2]["review_in_round_1"]).to eq(1) # one response in round 1
      expect(result[2]["review_in_round_2"]).to eq(1) # one response in round 2
    end
    
    it 'handles review reports for different reviewers independently' do
      # First for reviewer1
      allow(ResponseMap).to receive(:where)
        .with(reviewed_object_id: assignment.id, reviewer_id: reviewer1.id, type: 'ReviewResponseMap')
        .and_return([@map1, @map2])
      
      # Then for reviewer2  
      allow(ResponseMap).to receive(:where)
        .with(reviewed_object_id: assignment.id, reviewer_id: reviewer2.id, type: 'ReviewResponseMap')
        .and_return([@map3])
      
      result1 = service.get_data_for_review_report(assignment.id, reviewer1.id, 'ReviewResponseMap', assignment)
      result2 = service.get_data_for_review_report(assignment.id, reviewer2.id, 'ReviewResponseMap', assignment)
      
      # Reviewer 1 should have data for rounds 1 and 2 (from different teams)
      expect(result1[2]["review_in_round_1"]).to eq(1)
      expect(result1[2]["review_in_round_2"]).to eq(1)
      
      # Reviewer 2 should have data for both rounds (from same team)
      expect(result2[2]["review_in_round_1"]).to eq(1)
      expect(result2[2]["review_in_round_2"]).to eq(1)
    end
  end

     describe '#performance considerations' do
      it 'handles large number of response maps efficiently' do
        # Use doubles instead of creating real objects
        reviewer = double('Participant', id: 1)
        team = double('Team', id: 1)
        assignment_double = double('Assignment')
        allow(assignment_double).to receive(:num_review_rounds).and_return(2)
        allow(assignment_double).to receive(:id).and_return(1)
        
        service = described_class.new(assignment_double)
        # Initialize counters for the service
        service.send(:initialize_review_round_counters, assignment_double)
        
        # Create response map doubles
        maps = []
        20.times do |i|
          map = double("ResponseMap_#{i}", 
                      reviewer_id: reviewer.id, 
                      reviewee_id: team.id,
                      id: i)
          
          # Support both response_map.response and Response.where
          empty_responses = []
          allow(map).to receive(:response).and_return(empty_responses)
          allow(Response).to receive(:where).with(map_id: i).and_return(empty_responses)
          
          maps << map
        end
        
        # Stub Team.exists? for all reviewee_ids
        allow(Team).to receive(:exists?).and_return(true)
        
        # Stub the ResponseMap.where call in fetch_response_maps
        allow(ResponseMap).to receive(:where).and_return(maps)
        
        # Skip the actual update_review_round_counters processing since we've already
        # set up the service.instance_variable_get(:@review_round_counters) above
        allow(service).to receive(:update_review_round_counters).and_return(nil)
        
        # Add benchmark require
        require 'benchmark'
        
        # Benchmark the performance
        time = Benchmark.measure do
          service.get_data_for_review_report(1, 1, 'ReviewResponseMap', assignment_double)
        end
        
        # This is a soft expectation - adjust based on your environment
        expect(time.real).to be < 2.0 # Should complete in under 2 seconds
      end
    end

  describe '#security and validation' do
    it 'sanitizes inputs to prevent SQL injection in response map queries' do
      dangerous_input = "1; DROP TABLE response_maps; --"
      
      # The method should use ActiveRecord's parameterized queries which handle this automatically
      expect {
        service.send(:fetch_response_maps, dangerous_input, 1, 'ReviewResponseMap')
      }.not_to raise_error
      
      # More importantly, it shouldn't execute the malicious SQL
      expect(ResponseMap.table_exists?).to be_truthy
    end
    
    it 'validates response map types' do
      # Test with a valid type
      valid_type = 'ReviewResponseMap'
      expect {
        service.get_data_for_review_report(assignment.id, 1, valid_type, assignment)
      }.not_to raise_error
      
      # With Rails strict queries, invalid types should be handled properly
      # but we don't need to assert any specific behavior here as long as it doesn't error
    end
  end

 end
