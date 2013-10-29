require 'spec_helper'

describe 'admin edits a new assignment' do

    visit '/'

    page.should have_content('Expertiza')
    page.should have_content('Welcome to Expertiza')
    page.should have_content('Login')
    page.should have_content('User Name')
    page.should have_content('New Post')
    fill_in 'login_name', :with => 'admin'
    fill_in 'login_password', :with => 'expertiza'
    click_button 'Login'

    page.should have_content('Manage Content')
    page.should have_content('Questionnaires')
    page.should have_content('Courses ')
    page.should have_content('Sort by')
    page.should have_content(' Show public and private items ')

    visit 'tree_display/list'

    page.should have_content('Details')
    page.should have_content('Actions')
    page.should have_content('Assignments')

    find("Edit Assignment").click

    page.should have_content('Editing Assignment')
    page.should have_content('Private?')
    page.should have_content('Has teams?')
    page.should have_content('Micro-task assignment?')
    page.should have_content(' Wiki assignment?')

    click_link 'Rubrics'

    page.should have_content('Review')
    page.should have_content('Metareview')
    page.should have_content('Author Feedback')

    click_link 'Review strategy'
    page.should have_content('Review Strategy')
    page.should have_content('Maximum number of review per submission')
    page.should have_content('Back')

    click_link 'Due dates'
    page.should have_content('Number of Review Rounds')
    page.should have_content('Round 1: Review')
    page.should have_content('Date & time')

   click_button 'Logout'
    page.should have_content('Expertiza')
    page.should have_content('Welcome to Expertiza')
    page.should have_content('Login')
    page.should have_content('User Name')
    page.should have_content('Password')

end