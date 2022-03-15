describe JoinTeamRequestsHelper do
  let(:join_team_request1) { build(:join_team_request) }
  describe '#display_request_status' do
    # Pending Status
    context 'when the request is pending' do
      before(:each) do
        join_team_request1.status = 'P'
      end

      it 'returns the associated status' do
        expect(helper.display_request_status(join_team_request1)).to eq('Pending: A request has been made to join this team.')
      end
    end

    # Denied Status
    context 'when the request is denied' do
      before(:each) do
        join_team_request1.status = 'D'
      end

      it 'returns the associated status' do
        expect(helper.display_request_status(join_team_request1)).to eq('Denied: The team has denied your request.')
      end
    end

    # Accepted Status
    context 'when the request is accepted' do
      before(:each) do
        join_team_request1.status = 'A'
      end

      it 'returns the associated status' do
        expect(helper.display_request_status(join_team_request1)).to eq('Accepted: The team has accepted your request.\nYou should receive an invitation in \"Your Team\" page.')
      end
    end

    # Unexpected Status
    context 'when the request is accepted' do
      before(:each) do
        join_team_request1.status = 'a different status'
      end

      it 'returns the associated status' do
        expect(helper.display_request_status(join_team_request1)).to eq('a different status')
      end
    end
  end
end
