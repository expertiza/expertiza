describe QuizAssignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, name: 'no one') }
  let(:participant) { build(:participant, id: 1) }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:teammate_review_response_map) { build(:review_response_map, type: 'TeammateReviewResponseMap') }
  let(:topic) { build(:topic) }
  describe '#candidate_topics_for_quiz' do
    context 'when there are no signup topics' do
      it 'returns nil' do
        expect(assignment.candidate_topics_for_quiz).to eq(nil)
      end
    end
    context 'when there is a sign up topic but no team has signed up for topics' do
      it 'returns an empty set' do
        assignment.sign_up_topics << topic
        allow(assignment).to receive(:contributors).and_return([team])
        allow(assignment).to receive(:signed_up_topic).with(team).and_return(nil)
        expect(assignment.candidate_topics_for_quiz).to eq(Set.new)
      end
    end
    context 'when there is a sign up topic and the team has signed up for topics' do
      it 'returns a set of the topic' do
        assignment.sign_up_topics << topic
        allow(assignment).to receive(:contributors).and_return([team])
        allow(assignment).to receive(:signed_up_topic).with(team).and_return(topic)
        check_set = Set.new
        check_set.add(topic)
        expect(assignment.candidate_topics_for_quiz).to eq(check_set)
      end
    end
  end
  describe '#quiz_taken_by?' do
    context 'when the participant has taken one quizzes' do
      it 'returns true' do
        allow(QuizQuestionnaire).to receive(:find_by).with(instructor_id: 6).and_return(questionnaire1)
        allow(QuizResponseMap).to receive(:where).with('reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?', 6, 1, 1).and_return([teammate_review_response_map])
        expect(assignment.quiz_taken_by?(instructor, participant)).to eq(true)
      end
    end
  end
  describe '#contributor_for_quiz' do
    context 'when no topic is selected' do
      it 'raises an error' do
        assignment.sign_up_topics << topic
        expect { assignment.contributor_for_quiz(participant, nil) }.to raise_error('Please select a topic.')
      end
    end
    context 'when the assignment does not have topics' do
      it 'raises an error' do
        expect { assignment.contributor_for_quiz(participant, topic) }.to raise_error('This assignment does not have topics.')
      end
    end
    context 'when the quiz has already been taken' do
      it 'raises an error' do
        assignment.sign_up_topics << topic
        allow(assignment).to receive(:candidate_topics_for_quiz).and_return(Set.new)
        expect { assignment.contributor_for_quiz(participant, topic) }.to raise_error('Too many quizzes have been taken for this topic; please select another one.')
      end
    end
    context 'when the quiz has accepted too many submissions' do
      it 'raises an error' do
        assignment.sign_up_topics << topic
        check_set = Set.new
        check_set.add(topic)
        allow(assignment).to receive(:candidate_topics_for_quiz).and_return(check_set)
        expect { assignment.contributor_for_quiz(participant, topic) }.to raise_error('There are no more submissions to take quiz on for this topic.')
      end
    end
    context 'when only one team can take the quiz' do
      it 'return the team' do
        assignment.sign_up_topics << topic
        check_set = Set.new
        check_set.add(topic)
        allow(assignment).to receive(:candidate_topics_for_quiz).and_return(check_set)
        allow(assignment).to receive(:contributors).and_return([team])
        allow(assignment).to receive(:quiz_taken_by?).with(team, participant).and_return(false)
        allow(team).to receive(:includes?).with(participant).and_return(false)
        allow(assignment).to receive(:signed_up_topic).with(team).and_return(topic)
        expect(assignment.contributor_for_quiz(participant, topic)).to eq(team)
      end
    end
  end
end
