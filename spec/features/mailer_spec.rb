require 'rspec'
require 'test_helper'


describe 'Edit e-mail option' do
  fixtures :users

  it 'should edit E-mail address successfully' do
    session = Capybara::Session.new(:selenium)
    session.visit ('profile/edit')
    visit 'http://localhost:3000/profile/edit'
    fill_in 'E-mail address', with: 'ychen75@ncsu.edu'
    find_field('E-mail address').value.should eq 'ychen75@ncsu.edu'
  end

  it 'should set E-mail options under profile properly' do
    session = Capybara::Session.new(:selenium)
    session.visit ('profile/edit')
    expect(page).to have_current_path('profile/edit')
    page.check 'When someone else reviews my work'
    page.check 'When someone else submits work I am assigned to review'
    page.check 'When someone else reviews one of my reviews (metareviews my work)'

    my_box = find ('#When someone else reviews my work')
    my_box.should be_checked
    my_box = find ('#When someone else submits work I am assigned to review')
    my_box.should be_checked
    my_box = find ('#When someone else reviews one of my reviews (metareviews my work)')
    my_box.should be_checked
  end
end

describe 'Test mailer' do


  it 'should not send mail to nonexistent e-mail' do


  end


  it 'should send e-mail successfully' do


  end

end