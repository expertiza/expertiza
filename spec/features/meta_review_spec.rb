describe "meta review testing" do
  before(:each) do
      @assignment = create(:assignment, name: "automatic meta review test", max_team_size: 4)
      create(:assignment_node)
      create(:deadline_type, name: "submission")
      create(:deadline_type, name: "review")
      create(:deadline_type, name: "metareview")
      create(:deadline_type, name: "drop_topic")
      create(:deadline_type, name: "signup")
      create(:deadline_type, name: "team_formation")
      create(:deadline_right)
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      (1..10).each do |i|
        student = create :student, name: 'student' + i.to_s
        create :participant, assignment: @assignment, user: student
        if i % 3 == 1 and i != 10
          instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, name: 'team' + i.to_s))
          @team = instance_variable_get('@team' + (i / 3 + 1).to_s)
        end
        create :team_user, user: student, team: @team
      end
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

  def load_questionnaire(meta_reviewer_name)
    login_as(meta_reviewer_name)
    expect(page).to have_content "User: #{meta_reviewer_name}"
    expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"

    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"
  end

  it "show review to be reviewed to meta reviewer" do

    @student_reviewer = create :student, name: 'student_reviewer'
    @participant_reviewer = create :participant, assignment: @assignment, user: @student_reviewer
    @student_reviewer2 = create :student, name: 'student_reviewer2'
    @participant_reviewer2 = create :participant, assignment: @assignment, user: @student_reviewer2

    login_as("instructor6")
    visit "/review_mapping/list_mappings?id=#{@assignment.id}"
    # add_meta_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(@student_reviewer.name)
    click_link('add metareviewer')
    add_matareviewer(@student_reviewer2.name)
    expect(page).to have_content @student_reviewer2.name

    load_questionnaire(@student_reviewer2.name)

    expect(page).to have_content "Show review"
    click_link('Show review')
    expect(page).to have_content "Ratings"
  end
end
