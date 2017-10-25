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
  let(:quiz_questionaire) { build(:questionnaire, id: 2) }
  let(:student) { build(:student, name: "student2064", fullname: "2064, student", handle: "handle") }
  let(:assignment_questionnaire) { build(:assignment_questionnaire) }
  let(:assignment_questionnaire2) { build(:assignment_questionnaire, used_in_round: 1) }
  let(:topic) { build(:topic) }
  before(:each) do
    allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
    allow(participant).to receive(:team).and_return(team)
    allow(participant).to receive(:user).and_return(student)
  end

  describe '#dir_path' do
    it 'returns the directory path of current assignment' do
      expect(participant.dir_path).to eq "final_test"
    end
  end

  describe '#assign_quiz' do
    it 'creates a new QuizResponseMap record' do
      allow(QuizQuestionnaire).to receive(:find_by).with(instructor_id: 1).and_return(quiz_questionaire) # WHY CAN NOT DELETE THIS SENTENCE
      expect { participant.assign_quiz(participant, participant2, nil) }.to change { QuizResponseMap.count }.from(0).to(1)
      expect(participant.assign_quiz(participant, participant2, nil)).to be_an_instance_of(QuizResponseMap)
    end
  end

  describe '#reviewers' do
    it 'returns all the participants in this assignment who have reviewed the team where this participant belongs' do
      allow(ReviewResponseMap).to receive(:where).with(any_args).and_return([response_map]) # differences with .with(parameter)
      allow(AssignmentParticipant).to receive(:find).with(any_args).and_return(participant2)
      expect(participant.reviewers).to eq([participant2])
    end
  end

  describe '#review_score' do
    it 'returns the review score' do
      # diao yong de method tai duo le,er qie bu zhi dao sha yi si
      allow(review_questionnaire).to receive(:get_assessments_for).with(any_args).and_return([response])
      allow(review_questionnaire).to receive(:questions).and_return(question)
      allow(Answer).to receive(:compute_scores).with([response], question).and_return({avg: 100})
      allow(review_questionnaire).to receive(:max_possible_score).and_return(100)
      expect(participant.review_score).to eq(100)
    end
  end

  describe '#scores' do
    context 'when assignment is not varying rubric by round and not an microtask' do
      it 'calculates scores that this participant has been given' do
        expect(participant).to receive(:assignment_questionnaires)
        expect(assignment).to receive(:compute_total_score)
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(assignment).to receive(:is_microtask?).and_return(false)
        expect(assignment).to receive(:compute_total_score)
        expect(participant).to receive(:caculate_scores)
        participant.scores(question)
      end
    end

    context 'when assignment is varying rubric by round but not an microtask' do
      it 'calculates scores that this participant has been given' do
        expect(participant).to receive(:assignment_questionnaires)
        expect(assignment).to receive(:compute_total_score)
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        expect(participant).to receive(:merge_scores)
        allow(assignment).to receive(:is_microtask?).and_return(false)
        expect(assignment).to receive(:compute_total_score)
        expect(participant).to receive(:caculate_scores)
        participant.scores(question)
      end
    end

    context 'when assignment is not varying rubric by round but an microtask' do
      it 'calculates scores that this participant has been given' do
        expect(participant).to receive(:assignment_questionnaires)
        expect(assignment).to receive(:compute_total_score)
        allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        allow(assignment).to receive(:is_microtask?).and_return(true)
        expect(participant).to receive(:topic_total_scores)
        expect(assignment).to receive(:compute_total_score)
        expect(participant).to receive(:caculate_scores)
        participant.scores(question)
      end
    end
  end

  # included method
  describe '#assignment_questionnaires' do
    context 'when the round of questionnaire is nil' do
      it 'record the result as review scores' do
        scores = {}
        question_hash = {review: question}
        score_map = {max: 100, min: 100, avg: 100}
        allow(AssignmentQuestionnaire).to receive(:find_by).with(any_args).and_return(assignment_questionnaire)
        allow(review_questionnaire).to receive(:get_assessments_for).with(any_args).and_return([response])
        allow(Answer).to receive(:compute_scores).with(any_args).and_return(score_map)
        participant.assignment_questionnaires(question_hash, scores)
        expect(scores[:review][:assessments]).to eq([response])
        expect(scores[:review][:scores]).to eq(score_map)
      end
    end

    context 'when the round of questionnaire is not nil' do
      it 'record the result as review#{n} scores' do
        scores = {}
        question_hash = {review1: question}
        score_map = {max: 100, min: 100, avg: 100}
        allow(AssignmentQuestionnaire).to receive(:find_by).and_return(assignment_questionnaire2)
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(any_args).and_return([response])
        allow(Answer).to receive(:compute_scores).with(any_args).and_return(score_map)
        participant.assignment_questionnaires(question_hash, scores)
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
      allow(SignUpTopic).to receive(:find_by).with(any_args).and_return(topic)
      participant.topic_total_scores(scores)
      expect(scores[:total_score]).to eq(0)
      expect(scores[:max_pts_available]).to eq(0)
    end
  end

  describe '#caculate_scores' do
    context 'when the participant has the grade' do
      it 'his total scores equals his grade' do
        scores = {}
        expect(participant2.caculate_scores(scores)).to eq(100.0)
      end
    end
    context 'when the participant has the grade and the total score more than 100' do
      it 'return the score of a given participant with total score 100' do
        scores = {total_score: 110}

        expect(participant.caculate_scores(scores)).to eq({total_score: 100})
      end
    end
    context 'when the participant has the grade and the total score less than 100' do
      it 'return the score of a given participant with total score' do
        scores = {total_score: 90}
        expect(participant.caculate_scores(scores)).to eq({total_score: 90})
      end
    end
  end

  describe '#copy' do
    it 'copies assignment participants to a certain course' do
      expect(participant.copy(517)).to be_an_instance_of(CourseParticipant)
    end
  end

  describe '#feedback' do
    it 'returns corrsponding author feedback responses given by current participant' do
      allow(FeedbackResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])
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
      allow(ReviewResponseMap).to receive(:get_reviewer_assessments_for).with(team, participant2).and_return([response])
      expect(participant.reviews_by_reviewer(participant2)).to eq([response])
    end
  end

  describe '#quizzes_taken' do
    it 'returns corrsponding quiz responses given by current participant' do
      allow(QuizResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])
      expect(participant.quizzes_taken).to eq([response])
    end
  end

  describe '#metareviews' do
    it 'returns corrsponding metareview responses given by current participant' do
      allow(MetareviewResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])
      expect(participant.metareviews).to eq([response])
    end
  end

  describe '#teammate_reviews' do
    it 'returns corrsponding teammate review responses given by current participant' do
      allow(TeammateReviewResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])
      expect(participant.teammate_reviews).to eq([response])
    end
  end

  describe '#bookmark_reviews' do
    it 'returns corrsponding bookmark review responses given by current participant' do
      allow(BookmarkRatingResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])
      expect(participant.bookmark_reviews).to eq([response])
    end
  end

  describe '#files' do
    context 'when there is not subdirectory in current directory' do
      it 'returns all files in current directory' do
        allow(Dir).to receive(:[]).with("a/*").and_return(["a/k.rb"])
        allow(File).to receive(:directory?).with("a/k.rb").and_return(false)
        expect(participant.files("a")).to eq(["a/k.rb"])
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
        row = []
        allow(AssignmentParticipant).to receive(:check_info_and_create).with(any_args).and_raise("No user id has been specified.")
        expect(AssignmentParticipant).to receive(:check_info_and_create)
        expect { AssignmentParticipant.import(row, nil, nil, nil) }.to raise_error("No user id has been specified.")
      end
    end

    context 'when no user is found by offered username' do
      context 'when the record has less than 4 items' do
        it 'raises an ArgumentError' do
          row = ["user_name", "user_fullname", "name@email.com"]
          allow(AssignmentParticipant).to receive(:check_info_and_create).with(any_args).and_raise("The record containing #{row[0]} does not have enough items.")
          expect(AssignmentParticipant).to receive(:check_info_and_create)
          expect { AssignmentParticipant.import(row, nil, nil, nil) }.to raise_error("The record containing #{row[0]} does not have enough items.")
        end
      end

      context 'when the record has more than 4 items' do
        context 'when certain assignment cannot be found' do
          it 'creates a new user based on import information and raises an ImportError' do
            row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
            session = {user: participant}
            allow(User).to receive(:find_by).with(any_args).and_return(nil)
            allow(Assignment).to receive(:find).with(2).and_return(nil)
            expect { AssignmentParticipant.import(row, nil, session, 2) }.to raise_error("The assignment with id \"2\" was not found.").and change { User.count }.by(1)
          end
        end

        context 'when certain assignment can be found and assignment participant does not exists' do
          it 'creates a new user, new participant and raises an ImportError' do
            row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
            session = {user: participant}
            allow(User).to receive(:find_by_name).with(any_args).and_return(nil)
            allow(Assignment).to receive(:find).with(2).and_return(assignment)
            allow(AssignmentParticipant).to receive(:exists?).and_return(false)
            expect { AssignmentParticipant.import(row, nil, session, 2) }.to change { User.count }.by(1).and change { AssignmentParticipant.count }.by(1)
          end
        end
      end
    end
  end

  describe '.export' do
    it 'exports all participants in current assignment' do
      csv = []
      expect(AssignmentParticipant).to receive_message_chain(:where, :find_each).with(any_args).and_yield(participant)
      expect(AssignmentParticipant.export(csv, 1, any_args)).
          to eq([["student2064", "2064, student", "expertiza@mailinator.com", "Student", "instructor6", true, true, true, "handle"]])
    end
  end

  describe '#set_handle' do
    context 'when the user of current participant does not have handle' do
      it 'sets the user name as the handle of current participant' do
        allow(student).to receive_message_chain(:handle, :nil?).and_return(true)
        allow(student).to receive(:handle).and_return("")
        participant.set_handle
        expect(participant.handle).to eq("student2064")
      end
    end

    context 'when current assignment exists participants with same handle as the one of current user' do
      it 'sets the user name as the name of current participant' do
        allow(AssignmentParticipant).to receive(:exists?).with(any_args).and_return(true)
        participant.set_handle
        expect(participant.handle).to eq("student2064")
      end
    end

    context 'when current assignment does not have participants with same handle as the one of current user' do
      it 'sets the user name as the handle of current participant' do
        participant.set_handle
        expect(participant.handle).to eq("handle")
      end
    end
  end

  describe '#review_file_path' do
    it 'returns the file path for reviewer to upload files during peer review' do
      allow(ResponseMap).to receive(:find).with(any_args).and_return(response_map)
      allow(TeamsUser).to receive_message_chain(:find_by, :user_id).with(any_args).and_return(1)
      allow(Participant).to receive(:find_by).with(any_args).and_return(participant)
      expect(participant.review_file_path(1)).to eq("/home/expertiza_developer/expertiza/pg_data/instructor6/csc517/test/final_test/0_review/1")
    end
  end

  describe '#current_stage' do
    it 'returns stage of current assignment' do
      allow(SignedUpTeam).to receive(:topic_id).with(any_args).and_return(1)
      allow(assignment).to receive(:get_current_stage).with(1).and_return("Finished")
      expect(participant.current_stage).to eq("Finished")
    end
  end

  describe '#stage_deadline' do
    context 'when stage of current assignment is not Finished' do
      it 'returns current stage' do
        allow(SignedUpTeam).to receive(:topic_id).with(any_args).and_return(1)
        allow(assignment).to receive(:stage_deadline).with(1).and_return("Unknow")
        expect(participant.stage_deadline).to eq("Unknow")
      end
    end

    context 'when stage of current assignment not Finished' do
      context 'current assignment is not a staggered deadline assignment' do
        it 'returns the due date of current assignment' do
          allow(SignedUpTeam).to receive(:topic_id).with(any_args).and_return(1)
          allow(assignment).to receive(:stage_deadline).with(1).and_return("Finished")
          allow(assignment).to receive(:staggered_deadline?).and_return(false)
          allow(assignment).to receive_message_chain(:due_dates, :last, :due_at).and_return(1)
          expect(participant.stage_deadline).to eq("1")
        end
      end

      context 'current assignment is a staggered deadline assignment' do
        it 'returns the due date of current topic' do
          allow(SignedUpTeam).to receive(:topic_id).with(any_args).and_return(1)
          allow(assignment).to receive(:stage_deadline).with(1).and_return("Finished")
          allow(assignment).to receive(:staggered_deadline?).and_return(true)
          allow(TopicDueDate).to receive_message_chain(:find_by, :last, :due_at).and_return(1)
          expect(participant.stage_deadline).to eq("1")
        end
      end
    end
  end
end
