﻿describe AssignmentParticipant do
  let(:response) { build(:response) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:team2) { build(:assignment_team, id: 2) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response]) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1) } #what's the relationship between factory and let build
  let(:question) { double('Question') }
  let(:quiz_questionaire) { build(:questionnaire, id: 2) }   #why cannot use quiz:questionaire
  before(:each) do
    allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
    allow(participant).to receive(:team).and_return(team)
  end
  describe '#dir_path' do
    it 'returns the directory path of current assignment' do
      expect(participant.dir_path).to eq "final_test"
    end
  end

  describe '#assign_quiz' do
    it 'creates a new QuizResponseMap record' do
      allow(QuizQuestionnaire).to receive(:find_by).with(any_args).and_return(quiz_questionaire)#WHY CAN NOT DELETE THIS SENTENCE
      expect{participant.assign_quiz(participant,participant2,nil)}.to change {QuizResponseMap.count}.from(0).to(1)
      expect(participant.assign_quiz(participant,participant2,nil)).to be_an_instance_of(QuizResponseMap)
    end
  end

  describe '#reviewers' do
    it 'returns all the participants in this assignment who have reviewed the team where this participant belongs' do
      allow(ReviewResponseMap).to receive(:where).with(any_args).and_return([response_map]) #differences with .with(parameter)
      allow(AssignmentParticipant).to receive(:find).with(any_args).and_return(participant2)
      expect(participant.reviewers).to eq([participant2])
    end
  end

  describe '#review_score' do
    it 'returns the review score' do
      #diao yong de method tai duo le,er qie bu zhi dao sha yi si
      allow(review_questionnaire).to receive(:get_assessments_for).with(any_args).and_return([response])
      allow(review_questionnaire).to receive(:questions).and_return(question)
      allow(Answer).to receive(:compute_scores).with([response], question).and_return({avg:100})
      allow(review_questionnaire).to receive(:max_possible_score).and_return(100)
      expect(participant.review_score).to eq(100)
    end
  end

  describe '#scores' do
    context 'when assignment is not varying rubric by round and not an microtask' do
      it 'calculates scores that this participant has been given'
    end

    context 'when assignment is varying rubric by round but not an microtask' do
      it 'calculates scores that this participant has been given'
    end

    context 'when assignment is not varying rubric by round but an microtask' do
      it 'calculates scores that this participant has been given'
    end
  end

  describe '#copy' do
    it 'copies assignment participants to a certain course' do
      expect(participant.copy(517)).to be_an_instance_of(CourseParticipant)
    end
  end

  describe '#feedback' do
    it 'returns corrsponding author feedback responses given by current participant' do
      allow(FeedbackResponseMap).to receive(:get_assessments_for).with(any_args).and_return([response])  #make no sense
      expect(participant.feedback).to eq([response]) #make no sense
    end
  end

  describe '#reviews' do
    it 'returns corrsponding peer review responses given by current team' do
      expect(participant).to receive(:team).and_return(team)
      expect(ReviewResponseMap).to receive(:get_assessments_for).and_return([response])
      expect(participant.reviews).to eq([response]) #make no sense
    end
  end

  describe '#reviews_by_reviewer' do
    it 'returns corrsponding peer review responses given by certain reviewer' do
      expect(participant).to receive(:team).and_return(team)
      expect(ReviewResponseMap).to receive(:get_reviewer_assessments_for).and_return([response])
      expect(participant.reviews_by_reviewer).to eq([response])
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
    it "raise error if record is empty" do
      row = []
      expect { Participant.import(row, nil, nil, nil) }.to raise_error("No user id has been specified.")
    end

    it "raise error if record does not have enough items " do
      row = ["user_name", "user_fullname", "name@email.com"]
      expect {Participant.import(row, nil, nil, nil) }.to raise_error("The record containing #{row[0]} does not have enough items.")
    end

    it "raise error if course with id not found" do
      course = build(:course)
      session = {}
      row = []
      allow(Course).to receive(:find).and_return(nil)
      allow(session[:user]).to receive(:id).and_return(1)
      row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
      expect {Participant.import(row, nil, session, 2) }.to raise_error("The assignment with the id \"2\" was not found.")
    end

    it "creates assignment participant form record" do
      course = build(:course)
      session = {}
      row = []
      allow(Course).to receive(:find).and_return(course)
      allow(session[:user]).to receive(:id).and_return(1)
      row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
      course_part = Participant.p_import(row, nil, session, 2)
      expect(course_part).to be_an_instance_of(Participant)
    end
  end

  describe '.export' do
    it 'exports all participants in current assignment'
  end

  describe '#set_handle' do
    context 'when the user of current participant does not have handle' do
      it 'sets the user name as the handle of current participant'
    end

    context 'when current assignment exists participants with same handle as the one of current user' do
      it 'sets the user name as the name of current participant'
    end

    context 'when current assignment does not have participants with same handle as the one of current user' do
      it 'sets the user name as the handle of current participant'
    end
  end

  describe '#review_file_path' do
    it 'returns the file path for reviewer to upload files during peer review' do
      allow(ResponseMap).to receive(:find).with(any_args).and_return(response_map)
      allow(TeamsUser).to receive_message_chain(:find_by, :user_id).with(any_args).and_return(1)
      allow(Participant).to receive_message_chain(:find_by).with(any_args).and_return(participant)
      expect(participant.review_file_path(1)).to eq("/home/expertiza_developer/expertiza/pg_data/instructor6/csc517/test/final_test/0_review/1")

    end
  end

  describe '#current_stage' do
    it 'returns stage of current assignment' do
      allow(SignedUpTeam).to receive_(:topic_id).with(any_args).and_return(1)
      allow(assignment).to receive(:get_current_stage).with(1).and_return("Finished")
      expect(participant.current_stage).to eq("Finished")
    end
  end

  describe '#stage_deadline' do
    context 'when stage of current assignment is not Finished' do
      it 'returns current stage' do
        #allow(participant).to receive(:patent_id).and_return(1)
        #allow(participant).to receive(:user_id).and_return(1)
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
