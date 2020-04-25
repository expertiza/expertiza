describe AssignmentHelper do

  # E1936
  # Both AssignmentHelper#assignment_questionnaire and AssignmentHelper#questionnaire methods are removed from the
  # helpers/assignment_helper.rb since both methods contained duplicate implementation found in the different files
  # models/assignment.rb (Assignment class), models/assignment_form.rb (AssignmentForm class), and others.
  # To avoid all duplicate implementation, these methods are preserved only in the models/assignment_form.rb file and
  # tested there:
  # AssignmentForm#assignment_questionnaire
  # AssignmentForm#questionnaire

  describe '#questionnaire_options' do
    it 'throws exception if type argument nil' do
      expect { questionnaire_options(nil) }.to raise_exception(NoMethodError)
    end
  end
end
