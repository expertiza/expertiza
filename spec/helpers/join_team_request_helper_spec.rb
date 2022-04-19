describe JoinTeamRequestsHelper do
  let(:join_team_request1) { build(:join_team_request) }
  describe '#display_request_status' do
    context 'when the request is pending' do
      it 'returns the associated status' do
        expect(helper.display_request_status(join_team_request1)).to eq('Pending: A request has been made to join this team.')
      end
    end
  end
end
