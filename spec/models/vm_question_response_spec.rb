describe VmQuestionResponse  do
  let(:review_questionnaire) { build(:questionnaire) }
  let(:author_feedback_questionnaire) { AuthorFeedbackQuestionnaire.new }
  let(:teammate_review_questionnaire) { TeammateReviewQuestionnaire.new }
  let(:metareview_questionnaire) { MetareviewQuestionnaire.new }
  let(:assignment) { build(:assignment) }
  let(:question) { build(:question, id: 2, questionnaire: review_questionnaire, weight: 2, type: 'good') }
  let(:questions) { [question] }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 3, grade: 100) }
  let(:reviewee) { build(:participant, id: 4, grade: 100) }
  let(:response) { VmQuestionResponse.new(review_questionnaire, assignment, 1) }
  let(:answer) { double('Answer') }
  let(:reviews) { [double('Response', map_id: 1, response_id: 1)] }
  let!(:answer1) { create(:answer, id: 2) }
  let(:row) { VmQuestionResponseRow.new(2, 1, 1, 5, 1) }
  let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: 'Criterion', answer_length_threshold: 5, questionnaire: review_questionnaire, assignment: assignment }
  let(:tp) { TagPrompt.new(prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox') }

  describe '#initialize' do
    context 'when initialized with a review questionnaire' do
      it 'initializes the instance variables' do
        expect(response.round).to eq 1
        expect(response.rounds).to eq(2)
        expect(response.questionnaire_type).to eq('ReviewQuestionnaire')
        expect(response.questionnaire_display_type).to eq('Review')
        expect(response.list_of_rows).to eq([])
        expect(response.list_of_reviewers).to eq([])
        expect(response.list_of_reviews).to eq([])
      end
    end

    context 'when initialized with any other questionnaire type' do
      it 'initializes the instance variables' do
        response = VmQuestionResponse.new(metareview_questionnaire, assignment, 1)
        expect(response.round).to eq(1)
        expect(response.rounds).to eq(2)
        expect(response.questionnaire_display_type).to eq('Metareview')
        expect(response.list_of_rows).to eq([])
        expect(response.list_of_reviewers).to eq([])
        expect(response.list_of_reviews).to eq([])
      end
    end
  end

  describe '#add_questions' do
    it 'adds questions' do
      response.add_questions(questions)
      expect(response.list_of_rows.size).to eq(1)
      vm_question_response_row = response.list_of_rows.first
      expect(vm_question_response_row.class.to_s).to eq 'VmQuestionResponseRow'
      expect(vm_question_response_row.question_text).to eq('Test question:')
      expect(vm_question_response_row.question_id).to eq(2)
      expect(vm_question_response_row.weight).to eq(2)
      expect(vm_question_response_row.question_seq).to eq(1.00)
    end
  end

  describe '#add_reviews' do
    before(:each) do
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(Answer).to receive(:where).with(response_id: 1).and_return([answer])
      allow(response).to receive(:add_answer).with(answer).and_return(true)
    end

    context 'when initialized with a review questionnaire' do
      it 'adds reviews' do
        allow(ReviewResponseMap).to receive(:assessments_for).with(team).and_return(reviews)
        allow(ReviewResponseMap).to receive(:find).with(1).and_return(double('ReviewResponseMap', reviewer_id: 1))
        response.add_reviews(participant, team, false)
        expect(response.list_of_reviews.size).to eq(1)
        expect(response.list_of_reviewers.size).to eq(1)
        expect(response.list_of_reviews.first.map_id).to eq(1)
        expect(response.list_of_reviewers.first).to eq(participant)
      end
    end

    context 'when initialized with a author feedback questionnaire' do
      it 'adds reviews' do
        author_feedback_questionnaire.type = "AuthorFeedbackQuestionnaire"
        response = VmQuestionResponse.new(author_feedback_questionnaire, assignment, 1)
        allow(FeedbackResponseMap).to receive(:where).with(reviewer_id: 3).and_return([double(id: 1, reviewer_id: 3, reviewee_id: 4, response_id: 1)])
        response.add_reviews(participant, team, false)
        expect(response.list_of_reviews.size).to eq(1)
        expect(response.list_of_reviewers.size).to eq(1)
      end
    end

    context 'when initialized with a teammate review questionnaire' do
      it 'adds reviews' do
        teammate_review_questionnaire.type = "TeammateReviewQuestionnaire"
        response = VmQuestionResponse.new(teammate_review_questionnaire, assignment, 1)
        allow(participant).to receive(:teammate_reviews).and_return(reviews)
        allow(TeammateReviewResponseMap).to receive(:find_by).with(id: 1).and_return(double('TeammateReviewResponseMap', reviewer_id: 1))
        response.add_reviews(participant, team, false)
        expect(response.list_of_reviews.size).to eq(1)
        expect(response.list_of_reviewers.size).to eq(1)
        expect(response.list_of_reviews.first.map_id).to eq(1)
        expect(response.list_of_reviewers.first).to eq(participant)
      end
    end

    context 'when initialized with a meta review type' do
      it 'adds reviews' do
        metareview_questionnaire.type = "MetareviewQuestionnaire"
        response = VmQuestionResponse.new(metareview_questionnaire, assignment, 1)
        allow(participant).to receive(:metareviews).and_return(reviews)
        allow(MetareviewResponseMap).to receive(:find_by).with(id: 1).and_return(double('MetareviewResponseMap', reviewer_id: 1))
        response.add_reviews(participant, team, false)
        expect(response.list_of_reviews.size).to eq(1)
        expect(response.list_of_reviewers.size).to eq(1)
        expect(response.list_of_reviews.first.map_id).to eq(1)
        expect(response.list_of_reviewers.first).to eq(participant)
      end
    end
  end

  describe '#display_team_members' do
    it 'displays the members of the team' do
      allow(team).to receive(:participants).and_return([participant])
      response.add_team_members(team)
      allow(participant).to receive(:fullname).and_return('2065, student')
      expect(response.display_team_members).to eq('Team members: (2065, student) ')
    end
  end

  describe '#max_score_for_questionnaire' do
    context 'when there are no rows' do
      it 'return 0' do
        expect(response.max_score_for_questionnaire).to eq(0)
      end
    end
  end

  describe '#add_answer' do
    it 'returns a VmQuestionResponseScoreCell' do
      allow(response).to receive(:list_of_rows).and_return([row])
      allow(TagPromptDeployment).to receive(:where).and_return([tag_dep])
      allow(Question).to receive(:find).and_return(question)
      allow(TagPrompt).to receive(:find).and_return(tp)
      expect(response.add_answer(answer1)).to eq([])
    end
  end
end
