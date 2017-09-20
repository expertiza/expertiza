describe AssignmentParticipant do
  let(:response) { build(:response) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:team2) { build(:assignment_team, id: 2) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response]) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1) }
  let(:question) { double('Question') }
  before(:each) do
    allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
    allow(participant).to receive(:team).and_return(team)
  end
  describe '#dir_path' do
    it 'returns the directory path of current assignment'
  end

  describe '#assign_quiz' do
    it 'creates a new QuizResponseMap record'
  end

  describe '#reviewers' do
    it 'returns all the participants in this assignment who have reviewed the team where this participant belongs'
  end

  describe '#review_score' do
    it 'returns the review score'
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
    it 'copies assignment participants to a certain course'
  end

  describe '#feedback' do
    it 'returns corrsponding author feedback responses given by current participant'
  end

  describe '#reviews' do
    it 'returns corrsponding peer review responses given by current team'
  end

  describe '#reviews_by_reviewer' do
    it 'returns corrsponding peer review responses given by certain reviewer'
  end

  describe '#quizzes_taken' do
    it 'returns corrsponding quiz responses given by current participant'
  end

  describe '#metareviews' do
    it 'returns corrsponding metareview responses given by current participant'
  end

  describe '#teammate_reviews' do
    it 'returns corrsponding teammate review responses given by current participant'
  end

  describe '#bookmark_reviews' do
    it 'returns corrsponding bookmark review responses given by current participant'
  end

  describe '#files' do
    context 'when there is not subdirectory in current directory' do
      it 'returns all files in current directory'
    end

    context 'when there is subdirectory in current directory' do
      it 'recursively returns all files in current directory'
    end
  end

  describe ".import" do
    context 'when record is empty' do
      it 'raises an ArgumentError'
    end

    context 'when no user is found by offered username' do
      context 'when the record has less than 4 items' do
        it 'raises an ArgumentError'
      end

      context 'when the record has more than 4 items' do
        context 'when certain assignment cannot be found' do
          it 'creates a new user based on import information and raises an ImportError'
        end

        context 'when certain assignment can be found and assignment participant does not exists' do
          it 'creates a new user, new participant and raises an ImportError'
        end
      end
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
    it 'returns the file path for reviewer to upload files during peer review'
  end

  describe '#current_stage' do
    it 'returns stage of current assignment'
  end

  describe '#stage_deadline' do
    context 'when stage of current assignment is not Finished' do
      it 'returns current stage'
    end

    context 'when stage of current assignment not Finished' do
      context 'current assignment is not a staggered deadline assignment' do
        it 'returns the due date of current assignment'
      end

      context 'current assignment is a staggered deadline assignment' do
        it 'returns the due date of current topic'
      end
    end
  end
end
