require 'rspec'
require 'rails_helper'

describe 'add TA', js:true do

  before(:each) do
    @course=create(:course,name: 'TA course')
  end

  it "check to see if  can be added" do
    login_as('instructor6')

    student =create(:student)


    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"


    fill_in 'user_name', with: student.name


    expect do
      click_button 'Add TA'
      wait_for_ajax # E1721 changes test
    end.to change { TaMapping.count }.by 1
  end

  it "should display newly created course" do
    student = create(:student)
    login_as(student.name)
    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"

    expect(page).to have_content("TA course")
  end

  end



