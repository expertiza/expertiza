describe VmQuestionResponse do

  context 'when initialized with a valid assignment questionnaire' do
    let(:rq) { create(:questionnaire) }
    let(:aq) { create(:assignment_questionnaire) }
    let(:asmt) { create(:assignment) }
    let(:vm_rsp) { VmQuestionResponse.new(rq, asmt, 1) }
    let(:q0) { create(:question) }
    let(:header_q) { QuestionnaireHeader(q0) }
    let(:rvw_rsp_map) { create(:review_response_map) }
    let(:team) { double('team') }

    it 'adds reviews' do

      review = double('review1')
      allow(review).to receive_messages(:map_id => 1, :response_id => 1)
      ppnt0 = double('ppnt0') 
      allow(ppnt0).to receive_messages(:teammate_reviews => [review])
      reviewer = double('reviewer')
      allow(reviewer).to receive_messages(:fullname => 'Python', :reviewer_id => 7)
      mapping = double
      allow(mapping).to receive_messages(:reviewer_id => 7)
      
      allow(ReviewResponseMap).to receive_messages(:get_assessments_for => [review], :find => mapping)
      allow(Participant).to receive_messages(:find => reviewer)

      # vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, team, false)
      expect(vm_rsp.list_of_reviews.size).to eq 1
      expect(vm_rsp.list_of_reviewers.size).to eq 1
      expect(vm_rsp.list_of_reviews).to eq [review]
    end
    
    context 'when given a team' do
      it 'displays the members of the team' do
        team = double('team')
        ppnt0 = double('ppnt0')
        allow(ppnt0).to receive_messages :fullname => 'Julia'
        ppnt1 = double('ppnt0')
        allow(ppnt1).to receive_messages :fullname => 'Python'
        ppnt2 = double('ppnt0')
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
      let(:qs) { qs = Array.new(1) { q0 } }

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

    let(:response) { build(:response) }
    let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
    let(:instructor) { build(:instructor, id: 6) }
    let(:student) { build(:student, id: 3, name: 'no one') }
    let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
    let(:participant) { build(:participant, id: 3) }
    let(:participant1) { build(:participant, id: 1, assignment: assignment) }
    let(:participant2) { build(:participant, id: 2, grade: 100) }
    let(:question) { double('Question') }
    let(:team) { build(:assignment_team, id: 1, name: 'no team') }
    let(:response) { build(:response) }
    
    # allow(FeedbackResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])

    let(:rq) { create(:questionnaire) }
    
    let(:vm_rsp) { VmQuestionResponse.new( aufq, assignment, 1 ) }
    # let(:ans) { create(:answer, question_id: 1, answer: 3, comments: 'best music', response_id: 1) }
    let(:ans) { double('answer') }
    let(:aufq) { create(:questionnaire, name: "AuthorFeedbackQuestionnaire", type: 'AuthorFeedbackQuestionnaire') }
    let(:question2) { create(:question, questionnaire: aufq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }
    


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
      review = double('review')
      allow(review).to receive_messages(:map_id => 1, :response_id => 1)
      ppnt0 = double('ppnt0') 
      allow(ppnt0).to receive_messages(:feedback => [review])
      ppnt1 = double('ppnt1')
      allow(ppnt1).to receive_messages(:fullname => 'Python')
      mapping = double
      allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 2)
      tag_dep = double('tag_dep')
      allow(tag_dep).to receive_messages(:question_type => question2.type, :answer_length_threshold => 4,
        :tag_prompt_id => 1)
      allow(ans).to receive_messages(:question_id => 2, :answer => 3, 
        :comments => 'this is longer than 10 chars')
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
      review = double('review')
      allow(review).to receive_messages(:map_id => 1, :response_id => 1)
      ppnt0 = double('ppnt0') 
      allow(ppnt0).to receive_messages(:feedback => [review])
      ppnt1 = double('ppnt1')
      allow(ppnt1).to receive_messages(:fullname => 'Python')
      mapping = double
      allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 2)
      tag_dep = double('tag_dep')
      allow(tag_dep).to receive_messages(:question_type => question2.type, :answer_length_threshold => 4,
        :tag_prompt_id => 1)
      allow(ans).to receive_messages(:question_id => 2, :answer => 3, 
        :comments => 'this is longer than 10 chars')
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
    let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
    let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
    let(:participant) { build(:participant, id: 3) }
    let(:participant1) { build(:participant, id: 1, assignment: assignment) }
    let(:participant2) { build(:participant, id: 2, grade: 100) }
    let(:question) { double('Question') }
    let(:team) { build(:assignment_team, id: 1, name: 'no team') }    
    # allow(FeedbackResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])

    let(:rq) { create(:questionnaire) }
    
    let(:vm_rsp) { VmQuestionResponse.new( aufq, assignment, 1 ) }
    # let(:ans) { create(:answer, question_id: 1, answer: 3, comments: 'best music', response_id: 1) }
    let(:ans) { double('answer') }
    let(:aufq) { create(:questionnaire, name: "TeammateReviewQuestionnaire", type: 'TeammateReviewQuestionnaire') }
    let(:question2) { create(:question, questionnaire: aufq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }
    


    it 'adds reviews' do
      review = double('review1')
      allow(review).to receive_messages(:map_id => 1, :response_id => 1)
      ppnt0 = double('ppnt0') 
      allow(ppnt0).to receive_messages(:teammate_reviews => [review])
      ppnt1 = double('ppnt1')
      allow(ppnt1).to receive_messages(:fullname => 'Python')
      mapping = double
      allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 2)
      
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
    let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
    let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
    let(:participant) { build(:participant, id: 3) }
    let(:participant1) { build(:participant, id: 1, assignment: assignment) }
    let(:participant2) { build(:participant, id: 2, grade: 100) }
    let(:question) { double('Question') }
    let(:team) { build(:assignment_team, id: 1, name: 'no team') }    
    # allow(FeedbackResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])

    let(:rq) { create(:questionnaire) }
    
    let(:vm_rsp) { VmQuestionResponse.new( aufq, assignment, 1 ) }
    # let(:ans) { create(:answer, question_id: 1, answer: 3, comments: 'best music', response_id: 1) }
    let(:ans) { double('answer') }
    let(:aufq) { create(:questionnaire, name: "MetareviewQuestionnaire", type: 'MetareviewQuestionnaire') }
    let(:question2) { create(:question, questionnaire: aufq, weight: 2, id: 2, type: 'good') }
    let(:qs) { qs = Array.new(1) { question2 } }
    


    it 'adds reviews' do
      review = double('review1')
      allow(review).to receive_messages(:map_id => 1, :response_id => 1)
      ppnt0 = double('ppnt0') 
      allow(ppnt0).to receive_messages(:metareviews => [review])
      ppnt1 = double('ppnt1')
      allow(ppnt1).to receive_messages(:fullname => 'Python')
      mapping = double
      allow(mapping).to receive_messages(:first => mapping, :reviewer_id => 2)
      
      allow(MetareviewResponseMap).to receive_messages(:where => mapping)
      allow(Participant).to receive_messages(:find => ppnt1)

      vm_rsp.add_questions qs
      vm_rsp.add_reviews(ppnt0, '', false)
      expect(vm_rsp.list_of_reviews.size).to eq 1
      expect(vm_rsp.list_of_reviewers.size).to eq 1
      expect(vm_rsp.list_of_reviews).to eq [review]
    end


    
        # create(:questionnaire, name: "ReviewQuestionnaire#{i}")
        # let(:teammate_review_response_map) { build(:review_response_map, type: 'TeammateReviewResponseMap') }
        # create(:questionnaire, name: "TeammateReviewQuestionnaire#{i}", type: 'TeammateReviewQuestionnaire')



  end

end
