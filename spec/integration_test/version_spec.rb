require 'spec_helper'

describe 'Version' do
describe 'version table feature' do
  it 'should delete all entries of versions' do
    visit "/versions/index"
    click_link('Delete All')
    page.should have_content('Your versions table has been cleaned')
    #To change this template use File | Settings | File Templates.
    #true.should == false
  end
  end
  describe 'display version table entries' do
    it 'should list entries in version table' do
      visit '/'
      page.should have_content('Reusable learning objects through peer review')
      fill_in('login_name', :with => 'admin')
      fill_in('login_password', :with => 'adminkfgkd;gkd;')
      click_button('Login')
      page.should have_content('Manage content')
      click_link('Manage Versions Table')
      page.should have_content('Version Table')
      #To change this template use File | Settings | File Templates.
      #true.should == false
    end
  end
  end