describe Participant do
  let(:team) { build(:assignment_team, id: 1, name: 'myTeam') }
  let(:user) { build(:student, id: 4, name: 'no name', fullname: 'no two') }
  let(:team_user) { build(:team_user, id: 1, user: user, team: team) }
  let(:topic) { build(:topic) }
  let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, name: "John", fullname: "Doe, John", id: 2)) }
  let(:participant3) { build(:participant, can_review: false, user: build(:student, name: "King", fullname: "Titan, King", id: 3)) }
  let(:participant4) { Participant.new }
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:question1) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { Criterion.new(id: 2, weight: 2, break_before: true) }
  let(:questionnaire1) { ReviewQuestionnaire.new(id: 1, questions: [question1], max_question_score: 5) }
  let(:questionnaire2) { ReviewQuestionnaire.new(id: 2, questions: [question2], max_question_score: 5) }

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe '#team' do
    it 'returns the team of the participant' do
      allow(participant4).to receive(:user).and_return(user)
      allow(TeamsUser).to receive(:find_by).with(user: user).and_return(team_user)
      expect(participant4.team).to eq(team)
    end
  end

  describe '#response' do
    it 'Returns the participant responses' do
      allow(participant.response_maps).to receive(:map).and_return(response)
      expect(participant.responses).to eq(response)
    end
  end

  describe "#name" do
    it "returns the name of the user" do
      expect(participant.name).to eq("Jane")
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      expect(participant.fullname).to eq("Doe, Jane")
    end
  end

  describe '#handle' do
    it 'returns the handle of the participant' do
      expect(participant.handle(nil)).to eq("handle")
    end
  end

  describe '#delete' do
    it 'deletes a participant if no associations exist and force is nil' do
      expect(participant.delete(nil)).to eq(participant)
    end
    it 'deletes a participant if no associations exist and force is true' do
      expect(participant.delete(true)).to eq(participant)
    end
    it 'delete a participant with associations and force is true and multiple team_users' do
      allow(participant).to receive(:team).and_return(team)
      expect(participant.delete(true)).to eq(participant)
    end
    it 'delete participant with associations and force is true and single team_user' do
      allow(participant).to receive(:team).and_return(team)
      allow(team).to receive(:teams_users).and_return(length: 1)
      expect(participant.delete(true)).to eq(participant)
    end
    it 'raises error, delete participant with associations and force is nil' do
      allow(participant).to receive(:team).and_return(team)
      expect { participant.delete(nil) }.to raise_error.with_message("Associations exist for this participant.")
    end
  end

  #  method --> force_delete is tested via the testing of method --> delete

  describe '#topic_name' do
    it 'returns the participant topic name when nil' do
      expect(participant.topic_name).to eq('<center>&#8212;</center>')
    end
    it 'returns the participant topic name when not nil' do
      allow(participant).to receive(:topic).and_return(topic)
      expect(participant.topic_name).to eq("Hello world!")
    end
  end

  describe '#able_to_review' do
    it 'returns true when can_review is true' do
      expect(participant.able_to_review).to eq(true)
    end
    it '#returns false when can_review is false' do
      expect(participant3.able_to_review).to eq(false)
    end
  end

  describe '#email' do
    it 'sends an email to the participant' do
      expect { participant.email("Missing 'pw'", "Missing 'home_page'") }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  describe '#get_permissions' do
    it 'returns the permissions of participant' do
      expect(Participant.get_permissions('participant')).to contain_exactly([:can_submit, true], [:can_review, true], [:can_take_quiz, true])
    end
    it 'returns the permissions of reader' do
      expect(Participant.get_permissions('reader')).to contain_exactly([:can_submit, false], [:can_review, true], [:can_take_quiz, true])
    end
    it 'returns the permissions of reviewer' do
      expect(Participant.get_permissions('reviewer')).to contain_exactly([:can_submit, false], [:can_review, true], [:can_take_quiz, false])
    end
    it 'returns the permissions of submitter' do
      expect(Participant.get_permissions('submitter')).to contain_exactly([:can_submit, true], [:can_review, false], [:can_take_quiz, false])
    end
  end

  describe '#get_authorization' do
    it 'returns participant when no arguments are passed' do
      expect(Participant.get_authorization(nil, nil, nil)).to eq('participant')
    end
    it 'returns reader when no arguments are passed' do
      expect(Participant.get_authorization(false, true, true)).to eq('reader')
    end
    it 'returns submitter when no arguments are passed' do
      expect(Participant.get_authorization(true, false, false)).to eq('submitter')
    end
    it 'returns reviewer when no arguments are passed' do
      expect(Participant.get_authorization(false, true, false)).to eq('reviewer')
    end
  end

  describe '#sort_by_name' do
    it 'returns a sorted list of participants alphabetical by name' do
      unsorted = [participant3, participant, participant2]
      sorted = [participant, participant2, participant3]
      expect(Participant.sort_by_name(unsorted)).to eq(sorted)
    end
  end
end
