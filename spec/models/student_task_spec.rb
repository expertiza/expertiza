describe StudentTask do
  # Write your mocked object here!
  let(:participant) { build(:participant, id: 1, user_id: user.id, parent_id: assignment.id) }
  let(:participant2) { build(:participant, id: 2, user_id: user2.id, parent_id: assignment.id) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, username: 'qwertyui', id: 5) }
  let(:user3) { create(:student, username: 'qwertyui1234', id: 6) }
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment, name: 'assignment', directory_path: 'assignment') }
  let(:assignment2) { build(:assignment, name: 'assignment2', directory_path: 'assignment2') }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', parent_id: assignment.id, users: [user, user2]) }
  let(:team2) { create(:assignment_team, id: 2, name: 'team 2', parent_id: assignment2.id, users: [user3]) }
  let(:team_user) { create(:team_user, id: 3, team_id: team.id, user_id: user.id) }
  let(:team_user2) { create(:team_user, id: 4, team_id: team.id, user_id: user2.id) }
  let(:team2_user3) { create(:team_user, id: 5, team_id: team2.id, user_id: user3.id) }
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

  # Tests teamed students method which returns the unique students that are paired with the student at some point
  # within their course
  describe '#teamed_students' do
    context 'when not in any team' do
      it 'returns empty' do
        expect(StudentTask.teamed_students(user3)).to eq({})
      end
    end
    context 'when assigned in a cource_team ' do
      it 'returns empty' do
        allow(user).to receive(:teams).and_return([course_team])
        expect(StudentTask.teamed_students(user)).to eq({})
      end
    end
    context 'when assigned in a assignment_team ' do
      it 'returns the students they are teamed with' do
        allow(user).to receive(:teams).and_return([team])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: assignment.id).and_return(participant)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 5, parent_id: assignment.id).and_return(participant2)
        allow(Assignment).to receive(:find_by).with(id: team.parent_id).and_return(assignment)
        expect(StudentTask.teamed_students(user)).to eq(assignment.course_id => [user2.fullname])
      end
    end
  end

  # Gets the due dates of an assignment
  describe '#get_due_date_data' do
    context 'when called with assignment having empty due dates' do
      it 'return empty time_list array' do
        timeline_list = []
        StudentTask.get_due_date_data(assignment, timeline_list)
        expect(timeline_list).to eq([])
      end
    end
    context 'when called with assignment having due date' do
      context 'and due_at value nil' do
        it 'return empty time_list array' do
          allow(due_date).to receive(:deadline_type).and_return(deadline_type)
          timeline_list = []
          due_date.due_at = nil
          assignment.due_dates = [due_date]
          StudentTask.get_due_date_data(assignment, timeline_list)
          expect(timeline_list).to eq([])
        end
      end
      context 'and due_at value not nil' do
        it 'return time_list array' do
          allow(due_date).to receive(:deadline_type).and_return(deadline_type)
          timeline_list = []
          assignment.due_dates = [due_date]
          StudentTask.get_due_date_data(assignment, timeline_list)
          expect(timeline_list).to eq([{
                                        label: (due_date.deadline_type.name + ' Deadline').humanize,
                                        updated_at: due_date.due_at.strftime('%a, %d %b %Y %H:%M')
                                      }])
        end
      end
    end
  end

  # Verifies fetching of peer review data of a user and a timeline
  describe '#get_peer_review_data' do
    context 'when no review response mapped' do
      it 'returns empty' do
        timeline_list = []
        StudentTask.get_peer_review_data(user2, timeline_list)
        expect(timeline_list).to eq([])
      end
    end
    context 'when mapped to review response map' do
      it 'returns timeline array' do
        timeline_list = []
        allow(ReviewResponseMap).to receive_message_chain(:where, :find_each).with(reviewer_id: 1).with(no_args).and_yield(review_response_map)
        allow(review_response_map).to receive(:id).and_return(1)
        allow(Response).to receive_message_chain(:where, :last).with(map_id: 1).with(no_args).and_return(response)
        allow(response).to receive(:round).and_return(1)
        allow(response).to receive(:updated_at).and_return(Time.new(2019))
        timevalue = Time.new(2019).strftime('%a, %d %b %Y %H:%M')
        expect(StudentTask.get_peer_review_data(1, timeline_list)).to eq([{ id: 1, label: 'Round 1 peer review', updated_at: timevalue }])
      end
    end
  end

  # Verifies retrieval of feedback from author
  describe '#get_author_feedback_data' do
    context 'when no feedback response mapped' do
      it 'returns empty' do
        timeline_list = []
        StudentTask.get_author_feedback_data(user2, timeline_list)
        expect(timeline_list).to eq([])
      end
    end
    context 'when mapped to feedback response map' do
      it 'returns timeline array' do
        timeline_list = []
        allow(FeedbackResponseMap).to receive_message_chain(:where, :find_each).with(reviewer_id: 1).with(no_args).and_yield(review_response_map)
        allow(review_response_map).to receive(:id).and_return(1)
        allow(Response).to receive_message_chain(:where, :last).with(map_id: 1).with(no_args).and_return(response)
        allow(response).to receive(:updated_at).and_return(Time.now)
        timevalue = Time.now.strftime('%a, %d %b %Y %H:%M')
        expect(StudentTask.get_author_feedback_data(1, timeline_list)).to eq([{ id: 1, label: 'Author feedback', updated_at: timevalue }])
      end
    end
  end

  # Verrifies retrieval of submission data from submission
  describe '#get_submission_data' do
    context 'when no submission data mapped' do
      it 'returns nil' do
        timeline_list = []
        expect(StudentTask.get_submission_data(1, 1, timeline_list)).to eq(nil)
      end
    end
    context 'when submission data mapped and not submit hyperlink or Remove hyperlink' do
      it 'returns timeline_list' do
        timeline_list = []
        allow(SubmissionRecord).to receive_message_chain(:where, :find_each).with(team_id: 1, assignment_id: 1).with(no_args).and_yield(submission_record)
        allow(submission_record).to receive(:operation).and_return('testing_label')
        allow(submission_record).to receive(:updated_at).and_return(Time.new(2019))
        timevalue = Time.new(2019).strftime('%a, %d %b %Y %H:%M')
        expect(StudentTask.get_submission_data(1, 1, timeline_list)).to eq([{ label: 'Testing label', updated_at: timevalue }])
      end
    end
    context 'when submission data mapped and operation is submit_hyperlink' do
      it 'returns timeline_list with link' do
        timeline_list = []
        allow(SubmissionRecord).to receive_message_chain(:where, :find_each).with(team_id: 1, assignment_id: 1).with(no_args).and_yield(submission_record)
        allow(submission_record).to receive(:operation).and_return('Submit Hyperlink')
        allow(submission_record).to receive(:updated_at).and_return(Time.new(2019))
        timevalue = Time.new(2019).strftime('%a, %d %b %Y %H:%M')
        expect(StudentTask.get_submission_data(1, 1, timeline_list)).to eq([{ label: 'Submit hyperlink', updated_at: timevalue, link: 'www.wolfware.edu' }])
      end
    end
    context 'when submission data mapped and operation is Remove Hyperlink' do
      it 'returns timeline_list with link' do
        timeline_list = []
        allow(SubmissionRecord).to receive_message_chain(:where, :find_each).with(team_id: 1, assignment_id: 1).with(no_args).and_yield(submission_record)
        allow(submission_record).to receive(:operation).and_return('Remove Hyperlink')
        timevalue = Time.new(2019).strftime('%a, %d %b %Y %H:%M')
        allow(submission_record).to receive(:updated_at).and_return(Time.new(2019))
        expect(StudentTask.get_submission_data(1, 1, timeline_list)).to eq([{ label: 'Remove hyperlink', updated_at: timevalue, link: 'www.wolfware.edu' }])
      end
    end
  end

  # Verifies retrieval of timeline data
  describe '#get_timeline_data' do
    context 'when no timeline data mapped' do
      it 'returns nil' do
        allow(participant).to receive(:get_reviewer).and_return(participant)
        expect(StudentTask.get_timeline_data(assignment, participant, team)).to eq([])
      end
    end
  end
end
