describe Assessment360Controller do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 6) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:administrator) { build(:admin, id: 6) }
  let(:superadmin) { build(:superadmin, id: 6) }
  let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc', id: 1) }
  let(:assignment) do
    build(:assignment,
          id: 1,
          instructor_id: 6,
          due_dates: [due_date],
          microtask: true,
          staggered_deadline: true,
          teams: [build(:assignment_team)])
  end
  let(:assignment_list) { [assignment] }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:course_participant) { build(:course_participant, user_id: 1) }
  let(:student1) { build(:student, id: 1, username: :lily) }
  let(:assignment_with_participants) do
    build(:assignment,
          id: 1,
          name: 'test_assignment',
          instructor_id: 2,
          participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)],
          course_id: 1)
  end
  let(:participants_list) { [build(:participant, id: 1, user_id: 1, assignment: assignment)] }
  let(:assignment_with_participants_list) { [assignment_with_participants] }
  let(:empty_teammate_review) { [] }
  let(:empty_meta_review) { [] }
  let(:review1) { double('Review', average_score: 90) }
  let(:review2) { double('Review', average_score: 100) }
  let(:teammate_review) { [review1, review2] }
  let(:meta_review) { [review2] }
  let(:topic) { build(:topic, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team: team, topic: topic) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment) }
  let(:team_with_grade) { build(:assignment_team, id: 1, assignment: assignment, grade_for_submission: 95) }
  let(:participant) { build(:participant) }
  let(:scores) {}
  let(:topic) { build(:topic) }
  REDIRECT_PATH = 'http://example.com'.freeze

  describe 'checking controller permissions' do
    context 'when different roles call the controller' do
      it 'does not allow student' do
        request_params = { course_id: 1 }
        user_session = { user: student }
        get :all_students_all_reviews, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'allows TA' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'allows instructor' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'allows administrator' do
        stub_current_user(administrator, administrator.role.name, administrator.role)
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'allows super administrator' do
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#all_students_all_reviews' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = REDIRECT_PATH
        get 'all_students_all_reviews'
      end

      it 'redirects to back' do
        expect(response).to redirect_to(REDIRECT_PATH)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        allow(Course).to receive(:find).with('1').and_return(course)
        request.env['HTTP_REFERER'] = REDIRECT_PATH
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([]) # no participants
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :all_students_all_reviews, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(REDIRECT_PATH)
        expect(flash[:error]).to be_present
      end

      it 'has participants, next assignment participant does not exist, and avoids divide by zero' do
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :all_students_all_reviews, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:all_students_all_reviews)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[course_participant.id]).to eq({})
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil]).to eq({})
      end

      it 'has participants, next assignment participant exists, but there are no reviews' do
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(course_participant).to receive(:teammate_reviews).and_return(empty_teammate_review)
        allow(course_participant).to receive(:metareviews).and_return(empty_meta_review)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :all_students_all_reviews, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:all_students_all_reviews)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[nil]).to eq({})
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil]).to eq({})
      end

      it 'has participants, next assignment participant exists, but there are reviews' do
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(course_participant).to receive(:teammate_reviews).and_return(teammate_review)
        allow(course_participant).to receive(:metareviews).and_return(meta_review)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :all_students_all_reviews, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:all_students_all_reviews)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[course_participant.id][1]).to eq('95%')
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil][1]).to eq('100%')
      end
    end
  end

  describe '#course_student_grade_summary' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = REDIRECT_PATH
        get 'course_student_grade_summary'
      end

      it 'redirects to back' do
        expect(response).to redirect_to(REDIRECT_PATH)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        allow(Course).to receive(:find).with('1').and_return(course)
        request.env['HTTP_REFERER'] = REDIRECT_PATH
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(course).to receive(:assignments).and_return([assignment])
        allow(assignment).to receive(:reject).and_return(assignment)
        allow(course).to receive(:get_participants).and_return([]) # no participants
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(REDIRECT_PATH)
        expect(flash[:error]).to be_present
      end

      it 'has participants, next assignment participant does not exist' do
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_student_grade_summary)
      end

      it 'has participants, next assignment participant exists, but no team id exists' do
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(signed_up_team).to receive(:topic_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(SignUpTopic).to receive(:find_by).with(id: nil).and_return(topic)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_student_grade_summary)
        returned_assignment_grades = controller.instance_variable_get(:@assignment_grades)
        expect(returned_assignment_grades[course_participant.id]).to eq({})
        returned_peer_review_scores = controller.instance_variable_get(:@peer_review_scores)
        expect(returned_peer_review_scores[nil]).to eq({})
        returned_final_grades = controller.instance_variable_get(:@final_grades)
        expect(returned_final_grades[nil]).to eq(0)
      end

      it 'has participants, next assignment participant exists, but team id exists and maps are nil' do
        allow(Participant).to receive(:find_by).and_return(participant)
        allow(controller).to receive(:calculate_penalty).and_return({ submission: 0, review: 0, meta_review: 0 })
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(SignedUpTeam).to receive(:topic_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(SignUpTopic).to receive(:find_by).with(id: 1).and_return(topic)
        allow(TeamsUser).to receive(:team_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(Team).to receive(:find).with(1).and_return(team)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: course_participant.user_id, parent_id: assignment.id).and_return(course_participant)
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_student_grade_summary)
        returned_topics = controller.instance_variable_get(:@topics)
        expect(returned_topics[course_participant.id][1]).to eq(topic)
        returned_assignment_grades = controller.instance_variable_get(:@assignment_grades)
        expect(returned_assignment_grades[nil][1]).to eq(nil)
        returned_peer_review_scores = controller.instance_variable_get(:@peer_review_scores)
        expect(returned_peer_review_scores[nil][1]).to eq(nil)
        returned_final_grades = controller.instance_variable_get(:@final_grades)
        expect(returned_final_grades[nil]).to eq(0)
      end

      it 'has participants, next assignment participant exists, but team id exists and maps are not nil' do
        allow(Participant).to receive(:find_by).and_return(participant)
        allow(controller).to receive(:calculate_penalty).and_return({ submission: 0, review: 0, meta_review: 0 })
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(SignedUpTeam).to receive(:topic_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(SignUpTopic).to receive(:find_by).with(id: 1).and_return(topic)
        allow(TeamsUser).to receive(:team_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(Team).to receive(:find).with(1).and_return(team_with_grade)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: course_participant.user_id, parent_id: assignment.id).and_return(course_participant)
        allow_any_instance_of(Assessment360Controller).to receive(:participant_scores).with(course_participant, {}).and_return(review: { scores: { avg: 90 } })
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_student_grade_summary)
        returned_topics = controller.instance_variable_get(:@topics)
        expect(returned_topics[course_participant.id][1]).to eq(topic)
        returned_assignment_grades = controller.instance_variable_get(:@assignment_grades)
        expect(returned_assignment_grades[nil][1]).to eq(95)
        returned_peer_review_scores = controller.instance_variable_get(:@peer_review_scores)
        expect(returned_peer_review_scores[nil][1]).to eq(90)
        returned_final_grades = controller.instance_variable_get(:@final_grades)
        expect(returned_final_grades[nil]).to eq(95)
      end
    end
  end

  describe '#insure_existence_of' do
    context 'checking if the course participants are empty' do
      before(:each) do
        request.env['HTTP_REFERER'] = REDIRECT_PATH
        get 'insure_existence_of'
      end

      it 'redirects to back' do
        expect(response).to redirect_to(REDIRECT_PATH)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end
    context 'method is called' do
      before(:each) do
        allow(Course).to receive(:find).with('1').and_return(course)
        request.env['HTTP_REFERER'] = REDIRECT_PATH
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(course).to receive(:assignments).and_return([assignment])
        allow(assignment).to receive(:reject).and_return(assignment)
        allow(course).to receive(:get_participants).and_return([]) # no participants
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(REDIRECT_PATH)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe '#assignment_grade_summary' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = REDIRECT_PATH
        get 'assignment_grade_summary'
      end

      it 'redirects to back' do
        expect(response).to redirect_to(REDIRECT_PATH)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        allow(Course).to receive(:find).with('1').and_return(course)
        request.env['HTTP_REFERER'] = REDIRECT_PATH
      end

      it 'has participants, has team id' do
        allow(Participant).to receive(:find_by).and_return(participant)
        allow(controller).to receive(:calculate_penalty).and_return({ submission: 0, review: 0, meta_review: 0 })
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) # has participants
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(assignment_with_participants).to receive(:participants).and_return(participants_list)
        allow(participants_list).to receive(:find_by).with(user_id: course_participant.user_id).and_return(course_participant)
        allow(SignedUpTeam).to receive(:topic_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(SignUpTopic).to receive(:find_by).with(id: 1).and_return(topic)
        allow(TeamsUser).to receive(:team_id).with(assignment.id, course_participant.user_id).and_return(1)
        allow(Team).to receive(:find).with(1).and_return(team)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: course_participant.user_id, parent_id: assignment.id).and_return(course_participant)
        allow_any_instance_of(Assessment360Controller).to receive(:participant_scores).with(course_participant, {}).and_return(review: { scores: { avg: 90 } })
        request_params = { course_id: 1 }
        user_session = { user: instructor }
        get :course_student_grade_summary, params: request_params, session: user_session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_student_grade_summary)
        returned_topics = controller.instance_variable_get(:@topics)
        expect(returned_topics[course_participant.id][1]).to eq(topic)
        returned_assignment_grades = controller.instance_variable_get(:@assignment_grades)
        returned_peer_review_scores = controller.instance_variable_get(:@peer_review_scores)
        expect(returned_peer_review_scores[course_participant.id][1]).to eq(90)
        returned_final_grades = controller.instance_variable_get(:@final_grades)
      end
    end
  end
end
