describe MentorMeeting do
  let(:team1) { create(:team) }
  let(:team2) { create(:team) }

  let(:meeting1) { create(:mentor_meeting, team: team1, meeting_date: Date.today) }
  let(:meeting2) { create(:mentor_meeting, team: team2, meeting_date: Date.today + 1.day) }
  let(:meeting3) { create(:mentor_meeting, team: team1, meeting_date: Date.today + 2.days) }

  describe '.dates_for_teams' do
    it 'returns meetings grouped by team' do
      result = MentorMeeting.dates_for_teams

      expect(result[team1.id]).to contain_exactly(meeting1.meeting_date, meeting3.meeting_date)
      expect(result[team2.id]).to contain_exactly(meeting2.meeting_date)
    end

    it 'returns an empty hash when no meetings exist' do
      MentorMeeting.destroy_all
      expect(MentorMeeting.dates_for_teams).to be_empty
    end
  end
end
