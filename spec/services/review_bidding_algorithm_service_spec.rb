describe ReviewBiddingAlgorithmService do
  describe '#run_bidding_algorithm' do
    let(:service) { described_class.new }

    let(:input_data) do
      {
        'tid' => [5139, 5140, 5141, 5142],
        'users' => {
          45672 => {
            'bids' => [
              { 'tid' => 5139, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:46:08 EDT -04:00' },
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:46:10 EDT -04:00' },
              { 'tid' => 5141, 'priority' => 3, 'timestamp' => 'Wed, 19 Mar 2025 20:46:12 EDT -04:00' },
              { 'tid' => 5142, 'priority' => 4, 'timestamp' => 'Wed, 19 Mar 2025 20:46:18 EDT -04:00' }
            ],
            'otid' => nil
          },
          45673 => {
            'bids' => [
              { 'tid' => 5139, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:46:08 EDT -04:00' },
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:46:10 EDT -04:00' },
              { 'tid' => 5141, 'priority' => 3, 'timestamp' => 'Wed, 19 Mar 2025 20:46:12 EDT -04:00' },
              { 'tid' => 5142, 'priority' => 4, 'timestamp' => 'Wed, 19 Mar 2025 20:46:18 EDT -04:00' }
            ],
            'otid' => nil
          },
          45674 => {
            'bids' => [
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:47:20 EDT -04:00' },
              { 'tid' => 5139, 'priority' => 3, 'timestamp' => 'Wed, 19 Mar 2025 20:47:23 EDT -04:00' },
              { 'tid' => 5141, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:47:25 EDT -04:00' },
              { 'tid' => 5142, 'priority' => 4, 'timestamp' => 'Wed, 19 Mar 2025 20:47:27 EDT -04:00' }
            ],
            'otid' => nil
          },
          45675 => {
            'bids' => [
              { 'tid' => 5139, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:47:58 EDT -04:00' },
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:48:08 EDT -04:00' }
            ],
            'otid' => nil
          },
          45676 => {
            'bids' => [
              { 'tid' => 5139, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:50:18 EDT -04:00' },
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:50:23 EDT -04:00' },
              { 'tid' => 5141, 'priority' => 3, 'timestamp' => 'Wed, 19 Mar 2025 20:50:26 EDT -04:00' }
            ],
            'otid' => nil
          },
          45677 => {
            'bids' => [
              { 'tid' => 5139, 'priority' => 1, 'timestamp' => 'Wed, 19 Mar 2025 20:50:18 EDT -04:00' },
              { 'tid' => 5140, 'priority' => 2, 'timestamp' => 'Wed, 19 Mar 2025 20:50:23 EDT -04:00' },
              { 'tid' => 5141, 'priority' => 3, 'timestamp' => 'Wed, 19 Mar 2025 20:50:26 EDT -04:00' }
            ],
            'otid' => nil
          }
        },
        'max_accepted_proposals' => 3
      }
    end

    it 'returns the correct bid allocation in the expected format and assigns at least one topic to each participant' do
      result = ReviewBiddingAlgorithmService.run_bidding_algorithm(input_data)

      # Ensure the result is a hash
      expect(result).to be_a(Hash)

      # Ensure all users from the input are present in the result
      expect(result.keys).to match_array(input_data['users'].keys.map(&:to_s))

      # Ensure each user is assigned at least one topic
      result.each do |user_id, topics|
        expect(topics).to be_an(Array) # Ensure topics are in an array
        expect(topics).not_to be_empty # Ensure at least one topic is assigned
      end
    end
  end
end
