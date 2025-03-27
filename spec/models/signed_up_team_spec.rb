require 'rails_helper'

describe SignedUpTeam do
  let(:assignment) { create(:assignment) }
  let(:topic) { create(:topic, assignment: assignment) }
  let(:team) { create(:assignment_team) }
  let(:participant) { create(:participant, assignment: assignment) }
  let(:teams_participant) { create(:teams_participant, team: team, participant: participant) }

  describe 'associations' do
    it { should belong_to(:topic).class_name('SignUpTopic') }
    it { should belong_to(:team).class_name('Team') }
  end

  describe 'validations' do
    it { should validate_presence_of(:topic_id) }
    it { should validate_presence_of(:team_id) }
  end

  describe 'scopes' do
    describe '.by_team_id' do
      it 'returns signed up teams for a given team' do
        signed_up_team = create(:signed_up_team, team: team)
        expect(described_class.by_team_id(team.id)).to include(signed_up_team)
      end
    end

    describe '.waitlisted' do
      it 'returns waitlisted teams' do
        waitlisted_team = create(:signed_up_team, team: team, is_waitlisted: true)
        expect(described_class.waitlisted).to include(waitlisted_team)
      end
    end

    describe '.confirmed' do
      it 'returns confirmed teams' do
        confirmed_team = create(:signed_up_team, team: team, is_waitlisted: false)
        expect(described_class.confirmed).to include(confirmed_team)
      end
    end

    describe '.by_topic_id' do
      it 'returns signed up teams for a given topic' do
        signed_up_team = create(:signed_up_team, topic: topic)
        expect(described_class.by_topic_id(topic.id)).to include(signed_up_team)
      end
    end

    describe '.by_assignment_id' do
      it 'returns signed up teams for a given assignment' do
        signed_up_team = create(:signed_up_team, topic: topic)
        expect(described_class.by_assignment_id(assignment.id)).to include(signed_up_team)
      end
    end
  end

  describe '.find_team_participants' do
    it 'returns team participants for an assignment' do
      teams_participant
      participants = described_class.find_team_participants(assignment.id)
      expect(participants).to include(teams_participant)
    end
  end

  describe '.find_team_for_user' do
    it 'returns team for a user in an assignment' do
      teams_participant
      found_team = described_class.find_team_for_user(assignment.id, participant.user_id)
      expect(found_team).to eq(team)
    end

    it 'returns nil when user is not a participant' do
      found_team = described_class.find_team_for_user(assignment.id, -1)
      expect(found_team).to be_nil
    end
  end

  describe '.find_team_signup_topics' do
    it 'returns signup topics for a team' do
      signed_up_team = create(:signed_up_team, topic: topic, team: team)
      topics = described_class.find_team_signup_topics(assignment.id, team.id)
      expect(topics.first.topic_id).to eq(topic.id)
    end
  end

  describe '.release_topics_selected_by_team_for_assignment' do
    let(:waitlisted_team) { create(:signed_up_team, topic: topic, team: team, is_waitlisted: true) }
    let(:confirmed_team) { create(:signed_up_team, topic: topic, team: team, is_waitlisted: false) }

    it 'releases confirmed topics and updates waitlisted teams' do
      confirmed_team
      waitlisted_team
      described_class.release_topics_selected_by_team_for_assignment(team.id, assignment.id)
      expect(described_class.where(team_id: team.id)).to be_empty
    end

    it 'handles empty team signups gracefully' do
      expect {
        described_class.release_topics_selected_by_team_for_assignment(-1, assignment.id)
      }.not_to raise_error
    end
  end

  describe '.topic_id_by_team_id' do
    it 'returns topic_id for confirmed team' do
      signed_up_team = create(:signed_up_team, topic: topic, team: team, is_waitlisted: false)
      expect(described_class.topic_id_by_team_id(team.id)).to eq(topic.id)
    end

    it 'returns nil for waitlisted team' do
      create(:signed_up_team, topic: topic, team: team, is_waitlisted: true)
      expect(described_class.topic_id_by_team_id(team.id)).to be_nil
    end

    it 'returns nil for non-existent team' do
      expect(described_class.topic_id_by_team_id(-1)).to be_nil
    end
  end

  describe '.drop_signup_record' do
    it 'removes signup record for existing topic and team' do
      signed_up_team = create(:signed_up_team, topic: topic, team: team)
      expect {
        described_class.drop_signup_record(topic.id, team.id)
      }.to change(described_class, :count).by(-1)
    end

    it 'handles non-existent record gracefully' do
      expect {
        described_class.drop_signup_record(-1, -1)
      }.not_to raise_error
    end
  end

  describe '.drop_off_waitlists' do
    it 'removes all waitlisted records for a team' do
      create(:signed_up_team, topic: topic, team: team, is_waitlisted: true)
      create(:signed_up_team, topic: topic, team: team, is_waitlisted: true)
      expect {
        described_class.drop_off_waitlists(team.id)
      }.to change(described_class.waitlisted, :count).by(-2)
    end

    it 'handles team with no waitlisted records' do
      expect {
        described_class.drop_off_waitlists(-1)
      }.not_to raise_error
    end
  end

  describe 'instance methods' do
    describe '#waitlisted?' do
      it 'returns true for waitlisted team' do
        signed_up_team = create(:signed_up_team, is_waitlisted: true)
        expect(signed_up_team.waitlisted?).to be true
      end

      it 'returns false for confirmed team' do
        signed_up_team = create(:signed_up_team, is_waitlisted: false)
        expect(signed_up_team.waitlisted?).to be false
      end
    end

    describe '#confirmed?' do
      it 'returns true for confirmed team' do
        signed_up_team = create(:signed_up_team, is_waitlisted: false)
        expect(signed_up_team.confirmed?).to be true
      end

      it 'returns false for waitlisted team' do
        signed_up_team = create(:signed_up_team, is_waitlisted: true)
        expect(signed_up_team.confirmed?).to be false
      end
    end
  end
end
