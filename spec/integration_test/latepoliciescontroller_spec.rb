require 'spec_helper'

describe 'should check login' do
  it 'login successfully' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    page.should have_content('Manage Content')
  end
end

describe 'should check latepolicy page' do
  it 'page should open successfully' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    visit '/late_policies'
    page.should have_content('Listing late policies')
  end
end

describe 'should create new policy' do
  it 'create policy' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    visit '/assignments/new?private=0'
    fill_in('assignment_name', :with => 'test_assignment')
    click_button('Create')
    page.select('1', :from => 'assignment_course_id')
    click_link('Due dates')
    fill_in('datetimepicker_submission_round_1', :with => '2013/11/28 00:00 +0000')
    page.select('2', :from => 'due_date[submission_allowed_id]')
    fill_in('datetimepicker_review_round_1', :with => '2013/11/29 00:00 +0000')
    fill_in('datetimepicker_metareview', :with => '2013/11/30 00:00 +0000')
    click_link('New late policy')
    fill_in('late_policy_policy_name', :with => 'test_policy')
    fill_in('late_policy_penalty_per_unit', :with => '1')
    page.select('Hour', :from => 'late_policy_penalty_unit')
    fill_in('late_policy_max_penalty', :with => '10')
    click_button('Create')
    page.should have_content('test_policy')
  end
end

describe 'should create new assignment' do
  it 'should create new assignment with existing policy' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    visit '/assignments/new?private=0'
    fill_in('assignment_name', :with => 'test_assignment1')
    click_button('Create')
    page.select('1', :from => 'assignment_course_id')
    click_link('Due dates')
    fill_in('datetimepicker_submission_round_1', :with => '2013/11/28 00:00 +0000')
    page.select('2', :from => 'due_date[submission_allowed_id]')
    fill_in('datetimepicker_review_round_1', :with => '2013/11/29 00:00 +0000')
    fill_in('datetimepicker_metareview', :with => '2013/11/30 00:00 +0000')
    check('assignment_calculate_penalty')
    page.select('assignment[late_policy_id]', :from => '1')
    click_button('Save')
    page.should have_content('Assignment was successfully saved')
  end
end

describe 'should edit existing policy' do
  it 'edit policy' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    visit '/late_policies'
    page.should have_content('test_policy')
    click_link 'Edit'
    fill_in('late_policy_penalty_per_unit', :with => '2')
    click_button('Edit')
    page.should have content('Late policy was successfully updated.')
  end
end

describe 'should delete existing policy' do
  it 'delete policy' do
    visit '/'
    fill_in('login_name', :with => 'admin')
    fill_in('login_password', :with => 'admin')
    click_button('Login')
    visit '/late_policies'
    page.should have_content('test_policy')
    click_link 'Delete'
    page.should_not have content('test_policy')
  end
end

describe 'login as student' do
  it 'should login as student' do
    visit '/'
    fill_in('login_name', :with => 'student2')
    fill_in('login_password', :with => 'qazs')
    click_button('Login')
    click_link('Assignments')
    click_link('repo')
    click_link('Your work')
    page.should have_content('Score for repo')
  end
end

describe 'login as instructor' do
  it 'view scores as instructor' do
    visit '/'
    fill_in('login_name', :with => 'ins1')
    fill_in('login_password', :with => 'abcd')
    click_button('Login')
    visit '/grades/view?id=14'
    page.should have_content('Summary report')
    page.should have_content('Average Penalty')
    page.should have_content('Maximum Penalty')
  end
end