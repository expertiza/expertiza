describe 'teams as reviewers' do
  before(:each) do
    @assignment = create(:assignment, name: 'automatic review mapping test', max_team_size: 4, team_reviewing_enabled: true)
    create(:assignment_node)
    create(:deadline_type, name: 'submission')
    review_type = create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_questionnaire, assignment_id: @assignment.id)

    (1..10).each do |i|
      student = create :student, name: 'student' + i.to_s
      create :participant, assignment: @assignment, user: student
      if (i % 3 == 1) && (i != 10)
        instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, name: 'team' + i.to_s))
        @team = instance_variable_get('@team' + (i / 3 + 1).to_s)
      end
      create :team_user, user: student, team: @team
    end

    @assignment.team_reviewing_enabled = true
    date1 = create(:assignment_due_date, due_at: Date.yesterday)
    date2 = create(:assignment_due_date, due_at: Date.tomorrow + 1, deadline_type: review_type)
    @assignment.due_dates = [date1, date2]
    @assignment.save!
  end

  xit 'can allow team mates to edit the response' do
    user = User.where(username: 'student10').first
    student = AssignmentParticipant.where(user_id: user.id).first

    # login as student 10 and start working on the review
    login_as('student10')
    visit '/student_task/view?id=10}'
    click_link "Others' work"
    click_button 'Request a new submission to review'
    click_link 'Begin'
    fill_in 'review[comments]', with: 'Excellent work done!'
    click_button 'Save Review'
    logout

    # switch to their teammate, student 9 and check that student 10's comment is there
    login_as_other_user_and_view_review(9)
    expect(page).to have_content 'Excellent work done!'
    visit '/student_task/view?id=9'
    click_link "Others' work"

    # have student 9 modify the review comment to say something different
    click_link 'Edit'
    fill_in 'review[comments]', with: 'Decent work here'
    click_button 'Save Review'

    # check that student 9's changes are visible
    login_as_other_user_and_view_review(10)
    expect(page).to have_content 'Decent work here'
  end

  def login_as_other_user_and_view_review(student_num)
    login_as_other_user('student' + student_num.to_s)
    visit "/student_task/view?id=#{student_num}}"
    click_link "Others' work"
    click_link 'View'
  end
end
