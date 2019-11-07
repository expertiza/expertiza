describe AssignmentParticipant do
  let(:response) { build(:response) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:team2) { build(:assignment_team, id: 2) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response]) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, grade: 100) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1) }
  let(:question) { double('Question') }
  before(:each) do
    allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
    allow(participant).to receive(:team).and_return(team)
  end

  describe '#dir_path' do
    it 'returns the directory path of current assignment' do
      expect(participant.dir_path).to eq('final_test')
    end
  end

  describe '#assign_quiz' do
    it 'creates a new QuizResponseMap record' do
      allow(QuizQuestionnaire).to receive(:find_by).with(instructor_id: 1).and_return(double('QuizQuestionnaire', id: 1))
      expect { participant.assign_quiz(participant, participant2) }.to change { QuizResponseMap.count }.from(0).to(1)
      expect(QuizResponseMap.first.reviewee_id).to eq(1)
      expect(QuizResponseMap.first.reviewer_id).to eq(2)
    end
  end

  describe '#reviewers' do
    it 'returns all the participants in this assignment who have reviewed the team where this participant belongs' do
      allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', 1).and_return([response_map])
      allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
      expect(participant.reviewers).to eq([participant2])
    end
  end

  describe '#review_score' do
    it 'returns the review score' do
      allow(review_questionnaire).to receive(:get_assessments_for).with(participant).and_return([response])
      allow(review_questionnaire).to receive(:questions).and_return([question])
      allow(Answer).to receive(:compute_scores).with([response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(review_questionnaire).to receive(:max_possible_score).and_return(5)
      expect(participant.review_score).to eq(4.5)
    end
  end

  describe '#scores' do
    before(:each) do
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                         .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
      allow(review_questionnaire).to receive(:symbol).and_return(:review)
      allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([response])
      allow(Answer).to receive(:compute_scores).with([response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
    end
    context 'when assignment is not varying rubric by round and not an microtask' do
      it 'calculates scores that this participant has been given' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(participant.scores(review1: [question]).inspect).to eq("{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, "\
          "user_id: 2, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, "\
          "type: \"AssignmentParticipant\", handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, "\
          "can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review1=>{:assessments=>[#<Response id: nil, map_id: 1, "\
          "additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>], "\
          ":scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100}")
      end
    end

    context 'when assignment is varying rubric by round but not an microtask' do
      it 'calculates scores that this participant has been given' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        expect(participant.scores(review1: [question]).inspect).to eq("{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, "\
          "user_id: 2, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, "\
          "type: \"AssignmentParticipant\", handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, "\
          "can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review1=>{:assessments=>[#<Response id: nil, map_id: 1, "\
          "additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>], "\
          ":scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100, :review=>{:assessments=>[#<Response id: nil, map_id: 1, additional_comment: nil, "\
          "created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>], :scores=>{:max=>95, :min=>88, :avg=>90.0}}}")
      end
    end

    context 'when assignment is not varying rubric by round but an microtask' do
      it 'calculates scores that this participant has been given' do
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        assignment.microtask = true
        allow(SignUpTopic).to receive(:find_by).with(assignment_id: 1).and_return(double('SignUpTopic', micropayment: 66))
        expect(participant.scores(review1: [question]).inspect).to eq("{:participant=>#<AssignmentParticipant id: 1, can_submit: true, can_review: true, "\
          "user_id: 2, parent_id: 1, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, type: \"AssignmentParticipant\", "\
          "handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, "\
          ":review1=>{:assessments=>[#<Response id: nil, map_id: 1, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, "\
          "is_submitted: false>], :scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100, :max_pts_available=>66}")
      end
    end
  end

  describe '#compute_assignment_score' do
    before(:each) do
      allow(review_questionnaire).to receive(:symbol).and_return(:review)
      allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
    end

    context 'when the round of questionnaire is nil' do
      it 'record the result as review scores' do
        scores = {}
        question_hash = {review: question}
        score_map = {max: 100, min: 100, avg: 100}
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: nil))
        allow(review_questionnaire).to receive(:get_assessments_for).with(participant).and_return([response])
        allow(Answer).to receive(:compute_scores).with(any_args).and_return(score_map)
        participant.compute_assignment_score(question_hash, scores)
        expect(scores[:review][:assessments]).to eq([response])
        expect(scores[:review][:scores]).to eq(score_map)
      end
    end

    context 'when the round of questionnaire is not nil' do
      it 'record the result as review#{n} scores' do
        scores = {}
        question_hash = {review: question}
        score_map = {max: 100, min: 100, avg: 100}
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                           .and_return(double('AssignmentQuestionnaire', used_in_round: 1))
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([response])
        allow(Answer).to receive(:compute_scores).with(any_args).and_return(score_map)
        participant.compute_assignment_score(question_hash, scores)
        expect(scores[:review1][:assessments]).to eq([response])
        expect(scores[:review1][:scores]).to eq(score_map)
      end
    end
  end

  describe '#merge_scores' do
    context 'when all of the review_n are nil' do
      it 'set max, min, avg of review score as 0' do
        scores = {}
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        participant.merge_scores(scores)
        expect(scores[:review][:scores][:max]).to eq(0)
        expect(scores[:review][:scores][:min]).to eq(0)
        expect(scores[:review][:scores][:min]).to eq(0)
      end
    end

    context 'when the review_n is not nil' do
      it 'merge the score of review_n to the score of review' do
        score_map = {max: 100, min: 100, avg: 100}
        scores = {review1: {scores: score_map, assessments: [response]}}
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        participant.merge_scores(scores)
        expect(scores[:review][:scores][:max]).to eq(100)
        expect(scores[:review][:scores][:min]).to eq(100)
        expect(scores[:review][:scores][:min]).to eq(100)
      end
    end
  end

  describe '#topic_total_scores' do
    it 'set total_score and max_pts_available of score when topic is not nil' do
      scores = {total_score: 100}
      allow(SignUpTopic).to receive(:find_by).with(assignment_id: 1).and_return(double('SignUpTopic', micropayment: 1))
      participant.topic_total_scores(scores)
      expect(scores[:total_score]).to eq(1.0)
      expect(scores[:max_pts_available]).to eq(1)
    end
  end

  describe '#calculate_scores' do
    context 'when the participant has the grade' do
      it 'his total scores equals his grade' do
        scores = {}
        expect(participant2.calculate_scores(scores)).to eq(100.0)
      end
    end
    context 'when the participant has the grade and the total score more than 100' do
      it 'return the score of a given participant with total score 100' do
        scores = {total_score: 110}
        expect(participant.calculate_scores(scores)).to eq(total_score: 100)
      end
    end
    context 'when the participant has the grade and the total score less than 100' do
      it 'return the score of a given participant with total score' do
        scores = {total_score: 90}
        expect(participant.calculate_scores(scores)).to eq(total_score: 90)
      end
    end
  end

  describe '#copy' do
    it 'copies assignment participants to a certain course' do
      expect { participant.copy(123) }.to change { CourseParticipant.count }.from(0).to(1)
      expect(CourseParticipant.first.user_id).to eq(2)
      expect(CourseParticipant.first.parent_id).to eq(123)
    end
  end

  describe '#feedback' do
    it 'returns corrsponding author feedback responses given by current participant' do
      allow(FeedbackResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])
      expect(participant.feedback).to eq([response])
    end
  end

  describe '#reviews' do
    it 'returns corrsponding peer review responses given by current team' do
      allow(ReviewResponseMap).to receive(:get_assessments_for).with(team).and_return([response])
      expect(participant.reviews).to eq([response])
    end
  end

  describe '#reviews_by_reviewer' do
    it 'returns corrsponding peer review responses given by certain reviewer' do
      allow(ReviewResponseMap).to receive(:get_reviewer_assessments_for).with(team, participant).and_return([response])
      expect(participant.reviews_by_reviewer(participant)).to eq([response])
    end
  end

  describe '#quizzes_taken' do
    it 'returns corrsponding quiz responses given by current participant' do
      allow(QuizResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])
      expect(participant.quizzes_taken).to eq([response])
    end
  end

  describe '#metareviews' do
    it 'returns corrsponding metareview responses given by current participant' do
      allow(MetareviewResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])
      expect(participant.metareviews).to eq([response])
    end
  end

  describe '#teammate_reviews' do
    it 'returns corrsponding teammate review responses given by current participant' do
      allow(TeammateReviewResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])
      expect(participant.teammate_reviews).to eq([response])
    end
  end

  describe '#bookmark_reviews' do
    it 'returns corrsponding bookmark review responses given by current participant' do
      allow(BookmarkRatingResponseMap).to receive(:get_assessments_for).with(participant).and_return([response])
      expect(participant.bookmark_reviews).to eq([response])
    end
  end

  describe '#files' do
    context 'when there is not subdirectory in current directory' do
      it 'returns all files in current directory' do
        expect(participant.files('./hooks')).to eq(["./hooks/pre-commit"])
      end
    end

    context 'when there is subdirectory in current directory' do
      it 'recursively returns all files in current directory' do
        allow(Dir).to receive(:[]).with("a/*").and_return(["a/b"])
        allow(File).to receive(:directory?).with("a/b").and_return(true)
        allow(Dir).to receive(:[]).with("a/b/*").and_return(["a/b/k.rb"])
        allow(File).to receive(:directory?).with("a/b/k.rb").and_return(false)
        expect(participant.files("a")).to eq(["a/b/k.rb", "a/b"])
      end
    end
  end

  describe ".import" do
    context 'when record is empty' do
      it 'raises an ArgumentError' do
        expect { AssignmentParticipant.import({}, nil, nil, nil) }.to raise_error(ArgumentError, 'No user id has been specified.')
      end
    end

    context 'when no user is found by offered username' do
      context 'when the record has less than 4 items' do
        it 'raises an ArgumentError' do
          row = {name: 'no one', fullname: 'no one', email: 'no_one@email.com'}
          expect { AssignmentParticipant.import(row, nil, nil, nil) }.to raise_error('The record containing no one does not have enough items.')
        end
      end

      context 'when new user needs to be created' do
        let(:row) do
          {name: 'no one', fullname: 'no one', email: 'name@email.com', role:'user_role_name', parent: 'user_parent_name'}
        end
        let(:attributes) do
          {role_id: 1, name: 'no one', fullname: 'no one', email: 'name@email.com', email_on_submission: 'name@email.com',
           email_on_review: 'name@email.com', email_on_review_of_review: 'name@email.com'}
        end
        let(:test_user) do
          {name: 'abc', email: 'abcbbc@gmail.com'}
        end
        it 'create the user and number of mails sent should be 1' do
          ActionMailer::Base.deliveries.clear
          allow(ImportFileHelper).to receive(:define_attributes).with(row).and_return(attributes)
          allow(ImportFileHelper).to receive(:create_new_user) do
            test_user = User.new(name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com')
            test_user.id = 123
            test_user.save!
            test_user
          end
          #allow(ImportFileHelper).to receive(:create_new_user).with(attributes, {}).and_return()
          allow(Assignment).to receive(:find).with(1).and_return(assignment)
          allow(User).to receive(:exists?).with(name: 'no one').and_return(false)
          allow(participant).to receive(:set_handle).and_return('handle')
          allow(AssignmentParticipant).to receive(:exists?).and_return(false)
          allow(AssignmentParticipant).to receive(:create).and_return(participant)
          allow(AssignmentParticipant).to receive(:set_handle)
          expect{(AssignmentParticipant.import(row, nil, {}, 1))}.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'when the record has more than 4 items' do
        let(:row) do
          {name: 'no one', fullname: 'no one', email: 'name@email.com', role:'user_role_name', parent: 'user_parent_name'}
        end
        let(:attributes) do
          {role_id: 1, name: 'no one', fullname: 'no one', email: 'name@email.com', email_on_submission: 'name@email.com',
           email_on_review: 'name@email.com', email_on_review_of_review: 'name@email.com'}
        end
        before(:each) do
          allow(ImportFileHelper).to receive(:define_attributes).with(row).and_return(attributes)
          allow(ImportFileHelper).to receive(:create_new_user).with(attributes, {}).and_return(double('User', id: 1))
        end

        context 'when certain assignment cannot be found' do
          it 'creates a new user based on import information and raises an ImportError' do
            allow(Assignment).to receive(:find).with(1).and_return(nil)
            expect { AssignmentParticipant.import(row, nil, {}, 1) }.to raise_error('The assignment with id "1" was not found.')
          end
        end

        context 'when certain assignment can be found and assignment participant does not exists' do
          it 'creates a new user, new participant and raises an ImportError' do
            allow(Assignment).to receive(:find).with(1).and_return(assignment)
            allow(AssignmentParticipant).to receive(:exists?).with(user_id: 1, parent_id: 1).and_return(false)
            allow(AssignmentParticipant).to receive(:create).with(user_id: 1, parent_id: 1).and_return(participant)
            allow(participant).to receive(:set_handle).and_return('handle')
            expect(AssignmentParticipant.import(row, nil, {}, 1)).to be_truthy
          end
        end
      end
    end
  end

  describe '.export' do
    it 'exports all participants in current assignment' do
      allow(AssignmentParticipant).to receive_message_chain(:where, :find_each).with(parent_id: 1).with(no_args).and_yield(participant)
      allow(participant).to receive(:user).and_return(build(:student, name: 'student2065', fullname: '2065, student'))
      options = {'personal_details' => 'true', 'role' => 'true', 'handle' => 'true', 'parent' => 'true', 'email_options' => 'true'}
      expect(AssignmentParticipant.export([], 1, options)).to eq(
        [["student2065",
          "2065, student",
          "expertiza@mailinator.com",
          "Student",
          "instructor6",
          true,
          true,
          true,
          "handle"]]
      )
    end
  end

  describe '#set_handle' do
    let(:student) { build(:student, name: 'no one') }
    before(:each) do
      allow(participant).to receive(:user).and_return(student)
    end
    context 'when the user of current participant does not have handle' do
      it 'sets the user name as the handle of current participant' do
        student.handle = ''
        expect { participant.set_handle }.to change { AssignmentParticipant.count }.from(0).to(1)
        expect(AssignmentParticipant.first.handle).to eq('no one')
      end
    end

    context 'when current assignment exists participants with same handle as the one of current user' do
      it 'sets the user name as the name of current participant' do
        allow(AssignmentParticipant).to receive(:exists?).with(parent_id: 1, handle: 'handle').and_return(true)
        expect { participant.set_handle }.to change { AssignmentParticipant.count }.from(0).to(1)
        expect(AssignmentParticipant.first.handle).to eq('no one')
      end
    end

    context 'when current assignment does not have participants with same handle as the one of current user' do
      it 'sets the user name as the handle of current participant' do
        allow(AssignmentParticipant).to receive(:exist?).with(parent_id: 1, handle: 'handle').and_return(false)
        expect { participant.set_handle }.to change { AssignmentParticipant.count }.from(0).to(1)
        expect(AssignmentParticipant.first.handle).to eq('handle')
      end
    end
  end

  describe '#review_file_path' do
    it 'returns the file path for reviewer to upload files during peer review' do
      allow(ResponseMap).to receive(:find).with(1).and_return(build(:review_response_map))
      allow(TeamsUser).to receive(:find_by).with(team_id: 1).and_return(build(:team_user))
      allow(Participant).to receive(:find_by).with(parent_id: 1, user_id: 2).and_return(participant)
      expect(participant.review_file_path(1)).to match('pg_data/instructor6/csc517/test/final_test/0_review/1')
    end
  end

  describe '#current_stage' do
    it 'returns stage of current assignment' do
      allow(SignedUpTeam).to receive(:topic_id).with(1, 2).and_return(5)
      expect(participant.current_stage).to eq('Finished')
    end
  end

  describe '#stage_deadline' do
    context 'when stage of current assignment is not Finished' do
      it 'returns current stage' do
        allow(SignedUpTeam).to receive(:topic_id).with(1, 2).and_return(5)
        allow(assignment).to receive(:stage_deadline).with(5).and_return('submission')
        expect(participant.stage_deadline).to eq('submission')
      end
    end

    context 'when stage of current assignment not Finished' do
      before(:each) do
        allow(SignedUpTeam).to receive(:topic_id).with(1, 2).and_return(5)
        allow(assignment).to receive(:stage_deadline).with(5).and_return('Finished')
      end

      context 'current assignment is not a staggered deadline assignment' do
        it 'returns the due date of current assignment' do
          allow(assignment).to receive(:due_dates).and_return([build(:assignment_due_date, due_at: '2007-05-16')])
          expect(participant.stage_deadline).to match('2007-05-16')
        end
      end

      context 'current assignment is a staggered deadline assignment' do
        it 'returns the due date of current topic' do
          assignment.staggered_deadline = true
          allow(TopicDueDate).to receive(:find_by).with(parent_id: 5).and_return([build(:assignment_due_date, due_at: '2008-08-08')])
          expect(participant.stage_deadline).to match('2008-08-08')
        end
      end
    end
  end
end
