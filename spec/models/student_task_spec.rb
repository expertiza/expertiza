describe StudentTask do
  # Write your mocked object here!
  let(:participant) { build(:participant, id: 1, user_id: user.id, parent_id: assignment.id) }
  let(:participant2) { build(:participant, id: 2, user_id: user2.id, parent_id: assignment.id) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, name: 'qwertyui', id: 5) }
  let(:user3) { create(:student, name: 'qwertyui1234', id: 6) }
  let(:assignment) { build(:assignment, name: 'assignment', directory_path: 'assignment') }
  let(:assignment2) { build(:assignment, name: 'assignment2', directory_path: 'assignment2') }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', parent_id: assignment.id, users: [user, user2]) }
  let(:team2) { create(:assignment_team, id: 2, name: 'team 2', parent_id: assignment2.id, users: [user3]) }
  let(:team_user) { create(:team_user, id: 3, team_id: team.id, user_id: user.id) }
  let(:team_user2) { create(:team_user, id: 4, team_id: team.id, user_id: user2.id) }
  let(:team2_user3) { create(:team_user, id: 5, team_id: team2.id, user_id: user3.id) }
  let(:course) { build(:course) }
  let(:course_team) { create(:course_team, id: 3, name: 'course team 1', parent_id: course.id) }
  let(:cource_team_user) { create(:team_user, id: 6, team_id: course_team.id, user_id: user.id) }
  let(:cource_team_user2) { create(:team_user, id: 7, team_id: course_team.id, user_id: user2.id) }
  let(:topic) { build(:topic) }
  let(:topic2) { create(:topic, topic_name: 'TestReview') }
  let(:topic3) { create(:topic) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:deadline_type) { build(:deadline_type, id: 1) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team2) }
  let(:metareview_response_map) { build(:meta_review_response_map, reviewed_object_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map) }
  let(:response2) { build(:response, id: 2, map_id: 1, response_map: review_response_map) }
  let(:submission_record) { build(:submission_record, id: 1, team_id: 1, assignment_id: 1) }
  let(:student_task) do
    StudentTask.new(
      user: user,
      participant: participant,
      assignment: assignment,
      topic: topic3
    )
  end
  let(:student_task2) do
    StudentTask.new(
      user: user,
      participant: participant2,
      assignment: assignment,
      topic: topic2
    )
  end

  # Tests topic name to ensure it is stored or set as "-"
  describe '#topic_name' do
    it 'returns the topic name if given one' do
      allow(student_task2).to receive(:topic).and_return(topic2)
      expect(student_task2.topic_name).to eq('TestReview')
    end

    it 'returns - for blank name' do
      expect(student_task.topic_name).to eq('-')
    end
  end

  # Verifies completion status of a student task
  describe '#complete?' do
    it 'verifies a student task is complete' do
      allow(student_task).to receive(:stage_deadline).and_return('Complete')
      expect(student_task.complete?).to be true
    end
    it 'verifies a nil stage_deadline to not be complete' do
      allow(student_task).to receive(:stage_deadline).and_return('')
      expect(student_task.complete?).to be false
    end
  end

  # tests if hyperlinks or other content is submitted during the submission stage
  # current stage must be submission
  # the team has submitted some content
  describe 'content_submitted_in_current_stage?' do
    it 'checks if hyperlinks is submitted during submission stage' do
      student_task.current_stage = 'submission'
      allow(student_task).to receive_message_chain(:hyperlinks, :present).and_return(true)
      expect(student_task.content_submitted_in_current_stage?).to eq(true)
    end
  end

  # Tests the updating of the @hyperlinks instance variable based on participant's team
  # Does not verify operation of ||= call, only tests cases of right hand side
  describe '#hyperlinks' do
    it 'returns empty array if participant has no team' do
      allow(student_task).to receive_message_chain(:participant, :team, :nil?).and_return(true)
      expect(student_task.hyperlinks).to eq([])
    end
    it 'assigns returns populated hyperlinks instance if participant has team' do
      allow(student_task).to receive_message_chain(:participant, :team, :hyperlinks).and_return(['something'])
      allow(student_task).to receive_message_chain(:participant, :team, :nil?).and_return(false)
      expect(student_task.hyperlinks).to eq(['something'])
    end
  end

  # Verifies incomplete status of student task
  describe '#incomplete?' do
    it 'checks a student_task is incomplete' do
      expect(student_task.incomplete?).to be true
    end
  end

  # Verifies that a task has not started
  describe '#not_started?' do
    it 'verfies started status' do
      allow(student_task).to receive(:in_work_stage?).and_return(true)
      allow(student_task).to receive(:started?).and_return(true)
      expect(student_task.not_started?).to eq(false)
    end

    it 'is not started due to work stage' do
      allow(student_task).to receive(:in_work_stage?).and_return(false)
      allow(student_task).to receive(:started?).and_return(true)
      expect(student_task.not_started?).to eq(false)
    end
  end

  # Tests relative_deadline for proper assignment when stage_deadline is present
  describe '#relative_deadline' do
    it 'returns false without a valid stage deadline' do
      allow(student_task).to receive(:stage_deadline).and_return(nil)
      expect(student_task.relative_deadline).to be_falsey
    end
    it 'verifies a valid case where stage_deadline is present' do
      allow(student_task).to receive(:stage_deadline).and_return(true)
      allow(student_task).to receive(:time_ago_in_words).and_return('astring')
      expect(student_task.relative_deadline).to eq('astring')
    end
  end

  # Examines a task to determine if the task is a revision
  describe '#revision?' do
    it 'returns true if content is submitted' do
      allow(student_task).to receive(:content_submitted_in_current_stage?).and_return(true)
      allow(student_task).to receive(:reviews_given_in_current_stage?).and_return(false)
      allow(student_task).to receive(:metareviews_given_in_current_stage?).and_return(false)
      expect(student_task.revision?).to eq(true)
    end

    it 'returns true if reviews given is true' do
      allow(student_task).to receive(:content_submitted_in_current_stage?).and_return(false)
      allow(student_task).to receive(:reviews_given_in_current_stage?).and_return(true)
      allow(student_task).to receive(:metareviews_given_in_current_stage?).and_return(false)
      expect(student_task.revision?).to eq(true)
    end

    it 'returns true if metareviews given is true' do
      allow(student_task).to receive(:content_submitted_in_current_stage?).and_return(false)
      allow(student_task).to receive(:reviews_given_in_current_stage?).and_return(false)
      allow(student_task).to receive(:metareviews_given_in_current_stage?).and_return(true)
      expect(student_task.revision?).to eq(true)
    end
  end
  # Checks if metareview was given in current task stage
  describe '#metreviews_given_in_current_stage?' do
    it 'return true' do
      student_task.current_stage = 'metareview'
      allow(student_task).to receive(:metareviews_given?).and_return(true)
      expect(student_task.metareviews_given_in_current_stage?).to eq(true)
    end
  end
  # Checks if review was given in current task stage
  describe '#reviews_given_in_current_stage?' do
    it 'return true' do
      student_task.current_stage = 'review'
      allow(student_task).to receive(:reviews_given?).and_return(true)
      expect(student_task.reviews_given_in_current_stage?).to eq(true)
    end
  end

  # tests whether a student task has been started
  # if the task is not incomplete && is not in the revision stage
  # started? returns false
  # if the task is incomplete && is in the revision stage
  # started? returns true
  describe '#started?' do
    it 'is not started' do
      allow(student_task).to receive(:incomplete?).and_return(false)
      allow(student_task).to receive(:revision?).and_return(false)
      expect(student_task.started?).to eq(false)
    end

    it 'is started' do
      allow(student_task).to receive(:incomplete?).and_return(true)
      allow(student_task).to receive(:revision?).and_return(true)
      expect(student_task.started?).to eq(true)
    end
  end

  # Tests works stage to ensure state is represented correctly
  describe '#in_work_stage?' do
    it 'is true, submission is a work stage' do
      allow(student_task).to receive(:current_stage).and_return('submission')
      expect(student_task.in_work_stage?).to eq(true)
    end
    it 'is true, review is a work stage' do
      allow(student_task).to receive(:current_stage).and_return('review')
      expect(student_task.in_work_stage?).to eq(true)
    end
    it 'is true, metareview is a work stage' do
      allow(student_task).to receive(:current_stage).and_return('metareview')
      expect(student_task.in_work_stage?).to eq(true)
    end
    it 'is false, empty object' do
      allow(student_task).to receive(:current_stage).and_return('')
      expect(student_task.in_work_stage?).to eq(false)
    end
  end
end
