def login_and_assign_reviewer(user, assignment_id, student_num, submission_num)
  login_as(user)
  visit "/assignments/#{assignment_id}/edit"
  find_link('ReviewStrategy').click
  select 'Instructor-Selected', from: 'assignment_form_assignment_review_assignment_strategy'
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

describe 'review mapping' do
  before(:each) do
    @assignment = create(:assignment, name: 'automatic review mapping test', max_team_size: 4)
    create(:assignment_node)
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    (1..10).each do |i|
      student = create :student, name: 'student' + i.to_s
      create :participant, assignment: @assignment, user: student
      if (i % 3 == 1) && (i != 10)
        instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, name: 'team' + i.to_s))
        @team = instance_variable_get('@team' + (i / 3 + 1).to_s)
      end
      create :team_user, user: student, team: @team
    end
  end

  it 'can add reviewer then delete it', js: true do
    participant_reviewer = create :participant, assignment: @assignment
    participant_reviewer2 = create :participant, assignment: @assignment
    login_as('instructor6')
    visit "/review_mapping/list_mappings?id=#{@assignment.id}"

    # add_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(participant_reviewer.user.name)
    expect(page).to have_content participant_reviewer.user.name
    click_link('delete')
    expect(page).to have_content "The review mapping for \"#{@team1.name}\" and \"#{participant_reviewer.user.name}\" has been deleted"

    # add_meta_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(participant_reviewer.user.name)
    click_link('add metareviewer')
    add_matareviewer(participant_reviewer2.user.name)
    expect(page).to have_content participant_reviewer2.user.name

    # delete_meta_reviewer
    find(:xpath, "//a[@href='/review_mapping/delete_metareviewer?id=3']").click
    expect(page).to have_content "The metareview mapping for #{participant_reviewer.user.name} and #{participant_reviewer2.user.name} has been deleted"

    click_link('add metareviewer')
    add_matareviewer(participant_reviewer2.user.name)
    # delete_all_meta_reviewer
    click_link('delete all metareviewers')
    expect(page).to have_content "metareview mappings for contributor \"#{@team1.name}\" and reviewer \"#{participant_reviewer.user.name}\" have been deleted"

    first(:link, 'delete outstanding reviewers').click
    expect(page).to have_content "All review mappings for \"#{@team1.name}\" have been deleted"
  end

  it 'show error when assign both 2' do
    skip('skip test on automated review mapping, too time consuming')
    login_and_assign_reviewer('instructor6', @assignment.id, 2, 2)
    expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student), not both')
  end

  it 'show error when assign both 0' do
    skip('skip test on automated review mapping, too time consuming')
    login_and_assign_reviewer('instructor6', @assignment.id, 0, 0)
    expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student)')
  end

  it 'calculate review mapping from given review number per student' do
    skip('skip test on automated review mapping, too time consuming')
    login_and_assign_reviewer('instructor6', @assignment.id, 2, 0)
    num = ReviewResponseMap.where(reviewee_id: 1, reviewed_object_id: 1).count
    expect(num).to eq(7)
  end

  it 'calculate reviewmapping from given review number per submission' do
    skip('skip test on automated review mapping, too time consuming')
    login_and_assign_reviewer('instructor6', @assignment.id, 0, 7)
    num = ReviewResponseMap.where(reviewer_id: 1, reviewed_object_id: 1).count
    expect(num).to eq(2)
  end

  # E1721 changes: test for unsubmitting a review
  it 'can unsubmit a review', js: true do
    participant_reviewer = create :participant, assignment: @assignment
    login_and_assign_reviewer('instructor6', @assignment.id, 0, 2)
    # add_reviewer
    first(:link, 'add reviewer').click
    add_reviewer(participant_reviewer.user.name)
    expect(page).to have_content participant_reviewer.user.name

    # create new submitted review
    team = AssignmentTeam.find(1)
    map_id = team.review_mappings[0].map_id
    create(:response, map_id: map_id, is_submitted: true)

    visit "/review_mapping/list_mappings?id=#{@assignment.id}"
    expect(page).to have_content 'unsubmit'

    # unsubmit the review
    expect do
      click_link 'unsubmit'
      wait_for_ajax
    end.to change { Response.where(is_submitted: true).count }.by(-1)
  end
  # E1721 changes end
end
