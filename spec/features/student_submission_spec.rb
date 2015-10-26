require 'rails_helper'
require 'spec_helper'


RSpec.feature 'student login process' do

  scenario 'with valid email and password', :js => true do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    expect(page).to have_content 'submission'

    click_on 'WCAE 2015'
    expect(page).to have_content 'Your work'

    click_on 'Your work'
    expect(page).to have_content 'Hyperlinks'

    fill_in 'submission', :with => 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'
    click_on 'Upload link'
    expect(page).to have_content 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'

  end

end