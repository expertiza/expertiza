require 'rails_helper'

def login_and_assign_reviewer(user, assignment_id, student_num, submission_num)
  login_as(user)
  visit "/assignments/#{assignment_id}/edit"
  find_link('ReviewStrategy').click
  select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
  fill_in 'num_reviews_per_student', with: student_num
  choose 'num_reviews_submission'
  fill_in 'num_reviews_per_submission', with: submission_num
  click_on('Assign reviewers')
end

def add_reviewer(student_name)
  fill_in 'user_name', with: student_name
  click_on 'Add Reviewer'
  expect(page).to have_content student_name
end

def add_matareviewer(student_name)
  fill_in 'user_name', with: student_name
  click_on 'Add Metareviewer'
  expect(page).to have_content student_name
end

describe "review mapping", js: true do
  before(:each) do
    #  @assignment = create(:assignment, name: "automatic review mapping test", max_team_size: 4)
    # create(:assignment_node,node_object_id:@assignment.id)
    # # create(:deadline_type, name: "submission")
    # # create(:deadline_type, name: "review")
    # # create(:deadline_type, name: "metareview")
    # # create(:deadline_type, name: "drop_topic")
    # # create(:deadline_type, name: "signup")
    # # create(:deadline_type, name: "team_formation")
    # # create(:deadline_right)
    # # create(:deadline_right, name: 'Late')
    # # create(:deadline_right, name: 'OK')
    #
    # (1..10).each do |i|
    #    student = User.find_by( name: 'student' + i.to_s)
    #   #student = create :student, name: 'student' + i.to_s
    #   participant = create :participant, assignment: @assignment, user: student
    #   if i % 3 == 1 and i != 10
    #     instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, assignment:@assignment,name: 'review_mapping_team' + i.to_s))
    #     @team = instance_variable_get('@team' + (i / 3 + 1).to_s)
    #   end
    #   create :team_user, user: student, team: @team
    # end
    @assignment=Assignment.find_by(name:'automatic review mapping test')
    @student=User.find_by(name:'student7')
    @student2=User.find_by(name:'student8')
    @team=Team.find_by(name:'review_mapping_team1')
    @participant=Participant.find_by(user_id:@student.id,parent_id:@assignment.id)
  end

  it "can add reviewer then delete it" do
    if(ResponseMap.where(reviewed_object_id: @assignment.id).first!=nil)
      ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
    end
    login_and_assign_reviewer("instructor6", @assignment.id, 0, 0)
    sleep(100)
    # add_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(@student.name)
    expect(page).to have_content @student.name
    click_link('delete')
    expect(page).to have_content "The review mapping for \"#{@team.name}\" and \"#{@student.name}\" has been deleted"

    # add_meta_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(@student.name)
    click_link('add metareviewer')
    add_matareviewer(@student2.name)
    expect(page).to have_content @student2.name
    # delete_meta_reviewer
    all(:link, 'delete')[3].click

    #find(:xpath, "//a[@href='/review_mapping/delete_metareviewer?id=85']").click
    expect(page).to have_content "The metareview mapping for #{@student.name} and #{@student2.name} has been deleted"

    click_link('add metareviewer')
    add_matareviewer(@student2.name)
    # delete_all_meta_reviewer
    click_link('delete all metareviewers')
    expect(page).to have_content "All metareview mappings for contributor \"#{@team.name}\" and reviewer \"#{@student.name}\" have been deleted"

    first(:link, 'delete outstanding reviewers').click
    expect(page).to have_content "All review mappings for \"#{@team.name}\" have been deleted"

    ResponseMap.where(reviewed_object_id: @assignment.id).delete_all


  end

  it "show error when assign both 2" do
    login_and_assign_reviewer("instructor6", @assignment.id, 2, 2)
    expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student), not both')
  end

  it "show error when assign both 0" do
    login_and_assign_reviewer("instructor6", @assignment.id, 0, 0)
    expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student)')
  end

  it "calculate review mapping from given review number per student" do
    if(ResponseMap.where(reviewed_object_id: @assignment.id).first!=nil)
      ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
    end
    sleep(30)
    login_and_assign_reviewer("instructor6", @assignment.id, 2, 0)
    sleep(100)
    num = ResponseMap.where(reviewee_id: @team.id, reviewed_object_id: @assignment.id).count
    expect(num).to eq(7)
    ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
  end

  it "calculate reviewmapping from given review number per submission" do
    if(ResponseMap.where(reviewed_object_id: @assignment.id).first!=nil)
      ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
    end
    login_and_assign_reviewer("instructor6", @assignment.id, 0, 7)
    num = ResponseMap.where(reviewer_id: @participant.id, reviewed_object_id: @assignment.id).count
    expect(num).to eq(2)
    ResponseMap.where(reviewed_object_id: @assignment.id).delete_all
  end
end
