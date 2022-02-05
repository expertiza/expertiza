describe 'expert review' do
  ###
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_exception_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

  context 'when current assignment with single review round supports expert peer-review' do
    context 'expert review feature' do
      it 'works correctly'
      # on assignments#edit page
      # an instructor is able to do expert review and the data can be saved successfully
      # a TA is able to do expert review and the data can be saved successfully

      # on student_review#list page
      # a student is able to do peer review
      # the student is able to compare the results of expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results'
    end
  end

  context 'when current assignment with vary-rubric-by-round supports expert peer-review' do
    context 'expert review feature' do
      it 'works correctly'
      # round 1 with review rubric 1
      # on assignments#edit page
      # an instructor is able to do round 1 expert review with review rubric 1 and the data can be saved successfully
      # a TA is able to do round 1 expert review  with review rubric 1 and the data can be saved successfully

      # on student_review#list page
      # a student is able to do round 1 peer review  with review rubric 1
      # the student is able to compare the results of round 1 expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results

      # round 2 with review rubric 2
      # on assignments#edit page
      # an instructor is able to do round 2 expert review with review rubric 2 and the data can be saved successfully
      # a TA is able to do round 2 expert review  with review rubric 2 and the data can be saved successfully

      # on student_review#list page
      # a student is able to do round 2 peer review  with review rubric 2
      # the student is able to compare the results of round 1 and round 2 expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results
    end
  end
end
