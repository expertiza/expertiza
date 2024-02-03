module GradeHistoriesHelperSpec
  def assignment_setup
    create_assignment
    create_participants
    create_topic
    create_deadline_types
    create_deadline_rights
    create_assignment_due_date
    perform_student_tasks
  end
  
  private
  
  def create_assignment
    create(:assignment, name: 'Assignment1684', directory_path: 'Assignment1684')
  end
  
  def create_participants
    create_list(:participant, 3)
  end
  
  def create_topic
    create(:topic, topic_name: 'Topic')
  end
  
  def create_deadline_types
    %w[submission review metareview drop_topic signup team_formation].each do |name|
      create(:deadline_type, name: name)
    end
  end
  
  def create_deadline_rights
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
  end
  
  def create_assignment_due_date
    submission_deadline = DeadlineType.find_by(name: 'submission')
    due_date = Date.current + 1.day
    create(:assignment_due_date, deadline_type: submission_deadline, due_at: due_date)
  end
  
  def perform_student_tasks
    login_as('instructor6')
    user = User.find_by(name: 'student2064')
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Signup sheet'
    assignment_id = Assignment.first.id
    visit "/sign_up_sheet/sign_up?id=#{assignment_id}&topic_id=1"
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Your team'
  end
  
  def make_submission
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Your work'
    fill_in 'submission', with: 'https://www.ncsu.edu'
    click_on 'Upload link'
  end
end
