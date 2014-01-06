require 'spec_helper'

describe 'Course' do
  describe 'creating a new course' do
    it 'should create a new course' do
      visit '/course/new'
      page.should have_content('New Course')
      fill_in('course_name', :with => 'testcourse')
      fill_in('course_directory_path', :with => 'test')
      fill_in('course_info', :with => 'testcourse')
      click_button('Create')
      page.should have_content('Course "testcourse" has been created successfully.')
      click_link('undo')
      expect(page).to have_text('Previous action has been undone successfully.')
      click_link('redo')
      expect(page).to have_text('Previous action has been redone successfully.')
      #To change this template use File | Settings | File Templates.
      #true.should == false
    end
  end
   end