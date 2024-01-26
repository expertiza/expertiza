module AssignmentCreationHelper
  def get_questionnaire(finder_var = nil)
    if finder_var.nil?
      AssignmentQuestionnaire.find_by(assignment_id: @assignment.id)
    else
      AssignmentQuestionnaire.where(assignment_id: @assignment.id).where(questionnaire_id: get_selected_id(finder_var))
    end
  end

  def get_selected_id(finder_var)
    if finder_var == 'ReviewQuestionnaire2'
      ReviewQuestionnaire.find_by(name: finder_var).id
    elsif finder_var == 'AuthorFeedbackQuestionnaire2'
      AuthorFeedbackQuestionnaire.find_by(name: finder_var).id
    elsif finder_var == 'TeammateReviewQuestionnaire2'
      TeammateReviewQuestionnaire.find_by(name: finder_var).id
    end
  end

  def fill_assignment_form
    fill_in 'assignment_form_assignment_name', with: 'edit assignment for test'
    select('Course 2', from: 'assignment_form_assignment_course_id')
    fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory1'
    fill_in 'assignment_form_assignment_spec_location', with: 'testLocation1'
  end

  def assignment_creation_setup(privacy, name)
    login_as('instructor6')
    new_assignment_url = "/assignments/new?private=#{privacy}"
    visit new_assignment_url

    fill_in 'assignment_form_assignment_name', with: name
    select('Course 2', from: 'assignment_form_assignment_course_id')
    fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
  end

  def create_deadline_types
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
  end
end
