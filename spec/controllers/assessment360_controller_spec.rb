# As scoped for issue E1781, we will test the aspects of the assessment360
# controller used for the course_student_grade_summary view and feature.
# We aren't going to write the tests for functions used for all_students_all_reviews.
# If you are a student writing that functionality, feel free to remove this comment!

describe Assessment360Controller do
  let(:instructor) { build(:instructor, id: 6) }
  let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc', id: 1) }
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:assignment_list) { [assignment] }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:course_participant) { build(:course_participant, user_id: 1) }
  let(:student1) { build(:student, id: 1, name: :lily) }
  let(:assignment_with_participants) {build(:assignment, id: 1, name: "test_assignment", instructor_id: 2,
                                            participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)], course_id: 1)}
  let(:assignment_with_participants_list) { [assignment_with_participants] }
  let(:empty_teammate_review) { [] }
  let(:empty_meta_review) { [] }
  let(:review1) { double('Review', average_score: 90) }
  let(:review2) { double('Review', average_score: 100) }
  let(:teammate_review) { [review1, review2] }
  let(:meta_review) { [review2] }

  describe '#all_students_all_reviews' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "all_students_all_reviews"
      end

      it 'redirects to back' do
        expect(response).to redirect_to(:back)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([]) #no participants
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(:back)
        expect(flash[:error]).to be_present
      end

      it 'has participants, next assignment participant does not exist, and avoids divide by zero' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) #has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[nil]).to eq({})
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil]).to eq({})
      end

      it 'has participants, next assignment participant exists, but there are no reviews' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) #has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        allow(assignment_with_participants.participants).to receive(:find_by).with({:user_id=>course_participant.user_id}).and_return(course_participant)
        allow(course_participant).to receive(:teammate_reviews).and_return(empty_teammate_review)
        allow(course_participant).to receive(:metareviews).and_return(empty_meta_review)
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[nil]).to eq({})
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil]).to eq({})
      end

      it 'has participants, next assignment participant exists, but there are reviews' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_with_participants_list)
        allow(assignment_with_participants_list).to receive(:reject).and_return(assignment_with_participants_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) #has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        allow(assignment_with_participants.participants).to receive(:find_by).with({:user_id=>course_participant.user_id}).and_return(course_participant)
        allow(course_participant).to receive(:teammate_reviews).and_return(teammate_review)
        allow(course_participant).to receive(:metareviews).and_return(meta_review)
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
        returned_teammate_review = controller.instance_variable_get(:@teammate_review)
        expect(returned_teammate_review[nil][1]).to eq("95%")
        returned_meta_review = controller.instance_variable_get(:@meta_review)
        expect(returned_meta_review[nil][1]).to eq("100%")
      end
    end
  end

  describe '#course_student_grade_summary' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back' do
        expect(response).to redirect_to(:back)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return([assignment])
        allow(assignment).to receive(:reject).and_return(assignment)
        allow(course).to receive(:get_participants).and_return([]) #no participants
        params = {course_id: 1}
        session = {user: instructor}
        get :course_student_grade_summary, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(:back)
        expect(flash[:error]).to be_present
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return([assignment])
        allow(assignment).to receive(:reject).and_return(assignment)
        allow(course).to receive(:get_participants).and_return([course_participant]) #has participants
        params = {course_id: 1}
        session = {user: instructor}
        get :course_student_grade_summary, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
      end
    end
  end
end

