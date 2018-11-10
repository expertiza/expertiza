describe VmQuestionResponse do
  before(:all) do
  end

  let(:review_questionnaire) {build(:questionnaire, name: "ReviewQuestionnaire",
                        type: 'ReviewQuestionnaire')}
  let(:author_feedback_questionnaire) {create(:questionnaire, type: "AuthorFeedbackQuestionnaire")}
  let(:teammate_review_questionnaire) {create(:questionnaire, type: "TeammateReviewQuestionnaire")}
  let(:metareview_questionnaire) {create(:questionnaire, type: "MetareviewQuestionnaire")}

  let(:assignment) {build(:assignment)}

  let(:question) { create(:question, questionnaire: review_questionnaire, weight: 2, id: 2, type: 'good') }
  let(:questions) { qs = Array.new(1) { question } }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 3, grade: 100) }

  let(:review) do
    review = double('review')
    allow(review).to receive_messages(:map_id => 1, :response_id => 1)
    review
  end

  let(:mapping) do
    mapping = double('mapping')
    allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 7)
    mapping
  end

  let(:answer) do
    answer = double('answer')
    allow(answer).to receive_messages(:question_id => 2, :answer => 3,
                                   :comments => 'this is longer than 10 chars')
    answer
  end

  let(:participant0) do
    participant0 = double('participant0')
    allow(participant0).to receive_messages(:fullname => 'Julia', :teammate_reviews => [review],
                                     :metareviews => [review],
                                     :feedback => [review])
    participant0
  end

  let(:participant1) do
    participant1 = double('participant1')
    allow(participant1).to receive_messages(:fullname => 'Python', :reviewer_id => 7)
    participant1
  end

  describe '#initialize' do
    context 'when intitialized with a review questionnaire' do
      let(:response) { VmQuestionResponse.new(review_questionnaire, assignment, 1) }
      it 'initializes the instance variables' do
        expect(response.round).to eq 1
        expect(response.questionnaire_type).to eq "ReviewQuestionnaire"
        expect(response.rounds).to eq 2
      end
    end
    context 'when intitialized with any other questionnaire type' do
      let(:response) { VmQuestionResponse.new(metareview_questionnaire, assignment, 1) }
      it 'initializes the instance variables' do
        expect(response.round).to eq 1
        expect(response.questionnaire_type).to eq "MetareviewQuestionnaire"
        expect(response.rounds).to eq 2
      end
    end
  end
  describe '#add_questions' do
    let(:response) { VmQuestionResponse.new(review_questionnaire, assignment, 1) }
    it 'adds questions' do
      response.add_questions questions
      expect(response.max_score).to eq 5
      expect(response.list_of_rows.size).to eq 1
      expect(response.max_score_for_questionnaire()).to eq questions.size * review_questionnaire.max_question_score
    end
  end
  describe '#add_reviews' do
    context 'when intitialized with a review questionnaire' do
      let(:response) { VmQuestionResponse.new(review_questionnaire, assignment, 1) }
      it 'adds reviews' do
        allow(ReviewResponseMap).to receive_messages(:get_assessments_for => [review], :find => mapping)
        allow(Participant).to receive_messages(:find => participant1)
        response.add_reviews(participant0, team, false)
        expect(response.list_of_reviews.size).to eq 1
        expect(response.list_of_reviewers.size).to eq 1
        expect(response.list_of_reviews).to eq [review]
      end
    end
    context 'when intitialized with a author feedback questionnaire' do
      let(:response) { VmQuestionResponse.new(author_feedback_questionnaire, assignment, 1) }
      it 'adds reviews' do
        allow(FeedbackResponseMap).to receive_messages(:where => mapping)
        allow(Participant).to receive_messages(:find => participant1)
        response.add_reviews(participant0, team, false)
        expect(response.list_of_reviews.size).to eq 1
        expect(response.list_of_reviewers.size).to eq 1
        expect(response.list_of_reviews).to eq [review]
      end
    end
    context 'when intitialized with a teammate review questionnaire' do
      let(:response) { VmQuestionResponse.new(teammate_review_questionnaire, assignment, 1) }
      it 'adds reviews' do
        allow(TeammateReviewResponseMap).to receive_messages(:where => mapping)
        allow(Participant).to receive_messages(:find => participant1)
        response.add_reviews(participant0, team, false)
        expect(response.list_of_reviews.size).to eq 1
        expect(response.list_of_reviewers.size).to eq 1
        expect(response.list_of_reviews).to eq [review]
      end
    end
    context 'when intitialized with a meta review type' do
      let(:response) { VmQuestionResponse.new(metareview_questionnaire, assignment, 1) }
      it 'adds reviews' do
        allow(MetareviewResponseMap).to receive_messages(:where => mapping)
        allow(Participant).to receive_messages(:find => participant1)
        response.add_reviews(participant0, team, false)
        expect(response.list_of_reviews.size).to eq 1
        expect(response.list_of_reviewers.size).to eq 1
        expect(response.list_of_reviews).to eq [review]
      end
    end
  end
  describe '#display_team_members' do
    let(:response) { VmQuestionResponse.new(review_questionnaire, assignment, 1) }
    it 'displays the members of the team' do
      team = double('team')
      participant2 = double('participant2')
      allow(participant2).to receive_messages :fullname => 'R'
      team_member_names = [participant0, participant1, participant2]
      allow(team).to receive_messages(:participants => team_member_names)
      out = 'Team members:'
      response.add_team_members(team)
      team.participants.each do |participant|
        out = out + " (" + participant.fullname + ") "
      end
      expect(response.display_team_members).to eq out
    end
  end
  describe '#add_answer' do
    let(:response) { VmQuestionResponse.new(author_feedback_questionnaire, assignment, 1 ) }
    let(:tag_dep) do
      tag_dep = double('tag_dep')
      allow(tag_dep).to receive_messages(:question_type => question.type,
                                         :answer_length_threshold => 4,
                                         :tag_prompt_id => 1)
      tag_dep
    end
    it 'adds an answer' do
      allow(FeedbackResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => participant1)
      allow(Answer).to receive_messages(:where => [answer])
      allow(TagPromptDeployment).to receive_messages(:where => [tag_dep])
      allow(Question).to receive_messages(:find => question)
      allow(TagPrompt).to receive_messages(:find => true)
      allow(VmTagPromptAnswer).to receive_messages(:new => '')
      allow(VmQuestionResponseScoreCell).to receive_messages(:new => '')

      response.add_questions questions
      response.add_reviews(participant0, '', false)
    end
  end
  describe '#get_number_of_comments_greater_than_10_words' do
    let(:response) { VmQuestionResponse.new(author_feedback_questionnaire, assignment, 1 ) }
    let(:tag_dep) do
      tag_dep = double('tag_dep')
      allow(tag_dep).to receive_messages(:question_type => question.type,
                                         :answer_length_threshold => 4,
                                         :tag_prompt_id => 1)
      tag_dep
    end
    it 'returns number of comments greater than 10 words' do
      allow(FeedbackResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => participant1)
      allow(Answer).to receive_messages(:where => [answer])
      allow(TagPromptDeployment).to receive_messages(:where => [tag_dep])
      allow(Question).to receive_messages(:find => question)
      allow(TagPrompt).to receive_messages(:find => true)
      allow(VmTagPromptAnswer).to receive_messages(:new => '')
      allow(VmQuestionResponseScoreCell).to receive_messages(:new => '')
      
      row = double('row')
      allow(row).to receive_messages(:countofcomments => 7, :question_id => 2,
        :question_max_score => 5, :score_row => [3])
      allow(VmQuestionResponseRow).to receive_messages(:new => row)

      response.add_questions questions
      response.add_reviews(participant0, '', false)
      expect(response.list_of_rows.size).to eq 1
      response.get_number_of_comments_greater_than_10_words
      expect(response.list_of_rows[0].countofcomments).to eq 7
    end
  end
end
vm_question_response_spec.rb
Displaying vm_question_response_spec.rb.