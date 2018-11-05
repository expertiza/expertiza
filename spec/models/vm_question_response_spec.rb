describe VmQuestionResponse do
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

  let(:ans) do
    ans = double('answer')
    allow(ans).to receive_messages(:question_id => 2, :answer => 3,
                                   :comments => 'this is longer than 10 chars')
    ans
  end

  let(:ppnt0) do
    ppnt0 = double('ppnt0')
    allow(ppnt0).to receive_messages(:fullname => 'Julia', :teammate_reviews => [review],
                                     :metareviews => [review],
                                     :feedback => [review])
    ppnt0
  end

  let(:ppnt1) do
    ppnt1 = double('ppnt1')
    allow(ppnt1).to receive_messages(:fullname => 'Python', :reviewer_id => 7)
    ppnt1
  end

  let(:participant) { build(:participant, id: 3, grade: 100) }
  let(:assignment) { build(:assignment) }
  let(:team_assignment) { build(:assignment, id: 1, name: 'no assignment',
                                participants: [participant], teams: [team]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }

  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire, name: "ReviewQuestionnaire",
                        type: 'ReviewQuestionnaire') }
    let(:vm_rsp) { VmQuestionResponse.new(rq, assignment, 1) }
    let(:question2) { create(:question, questionnaire: rq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }


    it 'adds reviews' do
      allow(ReviewResponseMap).to receive_messages(:get_assessments_for => [review], :find => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)
      vm_rsp.add_reviews(ppnt0, team, false)
      expect(vm_rsp.list_of_reviews.size).to eq 1
      expect(vm_rsp.list_of_reviewers.size).to eq 1
      expect(vm_rsp.list_of_reviews).to eq [review]
    end
    
    context 'when given a team' do
      it 'displays the members of the team' do
        team = double('team')
        ppnt2 = double('ppnt2')
        allow(ppnt2).to receive_messages :fullname => 'R'
        team_member_names = [ppnt0, ppnt1, ppnt2]
        allow(team).to receive_messages(:participants => team_member_names)
        out = 'Team members:'
        vm_rsp.add_team_members(team)
        team.participants.each do |participant|
          out = out + " (" + participant.fullname + ") "
        end
        expect(vm_rsp.display_team_members).to eq out
      end
    end

    context 'when given a list of valid questions' do
      let(:qs) { qs = Array.new(1) { question2 } }

      it 'can calculate the max score for the questionnaire' do
        vm_rsp.add_questions qs
        expect(vm_rsp.max_score).to eq 5
        expect(vm_rsp.list_of_rows.size).to eq 1
        expect(vm_rsp.max_score_for_questionnaire()).to eq qs.size * rq.max_question_score
      end
    end

    it 'has the round value of the given questionnaire' do
      expect(vm_rsp.round).to eq 1
    end
  end

  context 'is initialized with an AuthorFeedbackQuestionnaire' do
    let(:vm_rsp) { VmQuestionResponse.new( aufq, assignment, 1 ) }
    let(:aufq) { create(:questionnaire, name: "AuthorFeedbackQuestionnaire",
                        type: 'AuthorFeedbackQuestionnaire') }
    let(:question2) { create(:question, questionnaire: aufq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }
    let(:tag_dep) do
      tag_dep = double('tag_dep')
      allow(tag_dep).to receive_messages(:question_type => question2.type,
                                         :answer_length_threshold => 4,
                                         :tag_prompt_id => 1)
      tag_dep
    end

    it 'adds reviews' do
      # review = double('review1')
      # review.stub(:map_id => 1, :response_id => 1)
      # allow(review).to receive_messages(:map_id => 1)
      # ppnt0 = double('ppnt0') 
      # allow(ppnt0).to receive_messages(:feedback => [review])
      # ppnt1 = double('ppnt1')
      # allow(ppnt1).to receive_messages(:fullname => 'Python')
      # mapping = double
      # allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 2)
      # allow(FeedbackResponseMap).to receive_messages(:where => mapping)
      # allow(Participant).to receive_messages(:find => ppnt1)

      # vm_rsp.add_questions qs
      # vm_rsp.add_reviews(ppnt0, '', false)
      # expect(vm_rsp.list_of_reviews.size).to eq 1
      # expect(vm_rsp.list_of_reviewers.size).to eq 1
      # expect(vm_rsp.list_of_reviews).to eq [ppnt1]
    end

    it 'adds answers' do
      allow(FeedbackResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)
      allow(Answer).to receive_messages(:where => [ans])
      allow(TagPromptDeployment).to receive_messages(:where => [tag_dep])
      allow(Question).to receive_messages(:find => question2)
      allow(TagPrompt).to receive_messages(:find => true)
      allow(VmTagPromptAnswer).to receive_messages(:new => '')
      allow(VmQuestionResponseScoreCell).to receive_messages(:new => '')

      vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, '', false)

    end

    it 'gets the number of comments greater than 10 words' do
      allow(FeedbackResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)
      allow(Answer).to receive_messages(:where => [ans])
      allow(TagPromptDeployment).to receive_messages(:where => [tag_dep])
      allow(Question).to receive_messages(:find => question2)
      allow(TagPrompt).to receive_messages(:find => true)
      allow(VmTagPromptAnswer).to receive_messages(:new => '')
      allow(VmQuestionResponseScoreCell).to receive_messages(:new => '')
      
      row = double('row')
      allow(row).to receive_messages(:countofcomments => 7, :question_id => 2,
        :question_max_score => 5, :score_row => [3])
      allow(VmQuestionResponseRow).to receive_messages(:new => row)

      vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, '', false)
      expect(vm_rsp.list_of_rows.size).to eq 1
      vm_rsp.get_number_of_comments_greater_than_10_words
      expect(vm_rsp.list_of_rows[0].countofcomments).to eq 7
    end
  end

  context 'is initialized with an TeammateReviewQuestionnaire' do
    let(:tmrq) { create(:questionnaire, name: "TeammateReviewQuestionnaire",
                        type: 'TeammateReviewQuestionnaire') }
    let(:vm_rsp) { VmQuestionResponse.new( tmrq, assignment, 1 ) }
    let(:question2) { create(:question, questionnaire: tmrq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }

    it 'adds reviews' do
      allow(TeammateReviewResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)

      vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, '', false)
      expect(vm_rsp.list_of_reviews.size).to eq 1
      expect(vm_rsp.list_of_reviewers.size).to eq 1
      expect(vm_rsp.list_of_reviews).to eq [review]
    end
  end

  context 'is initialized with an MetareviewQuestionnaire' do
    let(:mrq) { create(:questionnaire, name: "MetareviewQuestionnaire", type: 'MetareviewQuestionnaire') }
    let(:question2) { create(:question, questionnaire: mrq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }
    let(:vm_rsp) { VmQuestionResponse.new( mrq, assignment, 1 ) }


    it 'adds reviews' do
      allow(MetareviewResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)

      vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, '', false)
      expect(vm_rsp.list_of_reviews.size).to eq 1
      expect(vm_rsp.list_of_reviewers.size).to eq 1
      expect(vm_rsp.list_of_reviews).to eq [review]
    end

  end

end
