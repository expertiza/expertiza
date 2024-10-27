describe AnswerHelper do
  before(:each) do
    @assignment1 = create(:assignment, name: 'name1', directory_path: 'name1')
    @assignment2 = create(:assignment, name: 'name2', directory_path: 'name2')
    @questionnaire1 = create(:questionnaire)
    @questionnaire2 = create(:questionnaire)
    @questionnaire3 = create(:questionnaire)
    @question = create(:question, questionnaire_id: @questionnaire2.id)
    @deadline_type_sub = create(:deadline_type, name: 'submission')
    @deadline_type_rev = create(:deadline_type, name: 'review')
    @deadline_right = create(:deadline_right)
    @duedate1 = create(:assignment_due_date, id: 1, due_at: '2019-01-01 23:30:00', deadline_type: @deadline_type_sub, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment1.id, round: 1)
    @duedate2 = create(:assignment_due_date, id: 2, due_at: '2019-01-31 23:30:00', deadline_type: @deadline_type_rev, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment1.id, round: 1)
    @duedate3 = create(:assignment_due_date, id: 3, due_at: '2019-02-01 23:30:00', deadline_type: @deadline_type_sub, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment1.id, round: 2)
    @duedate4 = create(:assignment_due_date, id: 4, due_at: '3000-01-31 23:30:00', deadline_type: @deadline_type_rev, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment1.id, round: 2)
    @duedate5 = create(:assignment_due_date, id: 5, due_at: '2019-01-01 23:30:00', deadline_type: @deadline_type_sub, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment2.id, round: 1)
    @duedate6 = create(:assignment_due_date, id: 6, due_at: '2019-01-31 23:30:00', deadline_type: @deadline_type_rev, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment2.id, round: 1)
    @duedate7 = create(:assignment_due_date, id: 7, due_at: '2019-02-01 23:30:00', deadline_type: @deadline_type_sub, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment2.id, round: 2)
    @duedate8 = create(:assignment_due_date, id: 8, due_at: '3000-01-31 23:30:00', deadline_type: @deadline_type_rev, review_allowed_id: @deadline_right.id, review_of_review_allowed_id: @deadline_right.id, submission_allowed_id: @deadline_right.id, parent_id: @assignment2.id, round: 2)
    @assignment_questionnaire1 = create(:assignment_questionnaire, id: 1, assignment_id: @assignment1.id, questionnaire_id: @questionnaire1.id, used_in_round: 1)
    @assignment_questionnaire2 = create(:assignment_questionnaire, id: 2, assignment_id: @assignment1.id, questionnaire_id: @questionnaire2.id, used_in_round: 2)
    @assignment_questionnaire3 = create(:assignment_questionnaire, id: 3, assignment_id: @assignment2.id, questionnaire_id: @questionnaire3.id, used_in_round: nil)
    @user = create(:student, username: 'name', fullname: 'name')
    @participant = create(:participant, user_id: @user.id, parent_id: @assignment1.id)
    @response_map = create(:review_response_map, reviewer: @participant, assignment: @assignment1)
    @response = create(:response, response_map: @response_map, created_at: '2019-11-01 23:30:00')
    @answer = create(:answer, response_id: @response.id, question_id: @question.id, comments: 'comment')
  end

  describe '#delete_existing_responses' do
    context 'when the response is in reviewing period' do
      it 'deletes the answers' do
        allow(AnswerHelper).to receive(:log_answer_responses).with([@question.id], @questionnaire2.id).and_return([@answer.response_id])
        allow(AnswerHelper).to receive(:log_response_info).with([@answer.response_id]).and_return(@answer.response_id => { email: @user.email, answers: @answer.comments, name: @user.username, assignment_name: @assignment1.name })
        expect(AnswerHelper).to receive(:review_mailer).with(@user.email, @answer.comments, @user.username, @assignment1.name).and_return(true)
        expect(Answer.exists?(response_id: @answer.response_id)).to eql(true) # verify the answer exists before deleting
        AnswerHelper.delete_existing_responses([@question.id], @questionnaire2.id)
        expect(Answer.exists?(response_id: @answer.response_id)).to eql(false)
      end
    end
  end

  describe '#log_answer_responses' do
    it 'logs the response_id if in active period for each of the questions answers' do
      AnswerHelper.log_answer_responses([@question.id], @questionnaire2.id)
      expect(AnswerHelper.log_answer_responses([@question.id], @questionnaire2.id)).to eql([1])
    end
  end

  describe '#log_response_info' do
    it 'logs info from each response_id to be used in answer deletion' do
      AnswerHelper.log_response_info([@answer.response_id])
      expect(AnswerHelper.log_response_info([@answer.response_id])).to eql(1 => { email: 'expertiza@mailinator.com', answers: 'comment', username: 'name', assignment_name: 'name1' })
    end
  end

  describe '#review_mailer' do
    it 'calls method in Mailer to send emails' do
      allow(Mailer).to receive(:notify_review_rubric_change).with(
        to: @user.email,
        subject: 'Expertiza Notification: The review rubric has been changed, please re-attempt the review',
        body: {
          name: @user.username,
          assignment_name: @assignment1.name,
          answers: @answer.comments
        }
      ).and_return(@mail)
      allow(@mail).to receive(:deliver_now)
      expect(Mailer).to receive(:notify_review_rubric_change).once
      AnswerHelper.review_mailer(@user.email, @answer.comments, @user.username, @assignment1.name)
    end
  end

  describe '#delete_answers' do
    it 'deletes the answers corresponding to the provided answer ids' do
      expect(Answer.exists?(response_id: @answer.response_id)).to eql(true) # verify the answer exists before deleting
      AnswerHelper.delete_answers(@answer.response_id)
      expect(Answer.exists?(response_id: @answer.response_id)).to eql(false)
    end
  end

  describe '#in_active_period' do
    it 'returns false when the current time is not in active period' do
      expect(AnswerHelper.in_active_period(@questionnaire1.id)).to eql(false)
    end
    it 'returns true when the current time is in active period' do
      expect(AnswerHelper.in_active_period(@questionnaire2.id)).to eql(true)
    end
    it 'returns true when the current time is in any active period (multiple periods when round number is nil)' do
      expect(AnswerHelper.in_active_period(@questionnaire3.id)).to eql(true)
    end
  end
end
