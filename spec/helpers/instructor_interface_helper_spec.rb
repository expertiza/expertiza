require 'rails_helper'

module InstructorInterfaceHelperSpec
  def set_deadline_type
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
  end

  def set_deadline_right
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
  end

  def set_assignment_due_date
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
  end

  def assignment_setup
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    set_deadline_type
    set_deadline_right
    set_assignment_due_date
  end

  def instructor_login
    login_as("instructor6")
    visit '/tree_display/list'
    expect(page).to have_content("Manage content")
  end

  def invalid_user
    visit root_path
    fill_in 'login_name', with: 'instructor6'
    fill_in 'login_password', with: 'something'
    click_button 'SIGN IN'
    expect(page).to have_text('Incorrect password')
  end
end
