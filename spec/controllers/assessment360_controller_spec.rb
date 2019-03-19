# As scoped for issue E1781, we will test the aspects of the assessment360
# controller used for the course_student_grade_summary view and feature.
# We aren't going to write the tests for functions used for all_students_all_reviews.
# If you are a student writing that functionality, feel free to remove this comment!

describe Assessment360Controller do
  let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc') }

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

    context 'when course has participants' do
      # allow(Course).to receive(:find).with('1').and_return(course)
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

    context 'when course has participants' do
      # allow(Course).to receive(:find).with('1').and_return(course)
    end
  end
end

