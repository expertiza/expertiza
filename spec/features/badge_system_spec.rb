def login_and_go_to_badge(user,assignment_id)
  login_as(user)
  visit "/assignments/#{assignment_id}/edit"
  find_link('Badges').click
end

def change_good_reviewer_badge_threshold(threshold)
  fill_in badge_1_threshold, with: threshold
  click_button "Save"
end

def change_good_teammate_badge_threshold(threshold)
  fill_in badge_2_threshold, with: threshold
  click_button "Save"
end

describe 'Good Reviewer Badge Presence' do

  before :each do

    create(:assignment, name: 'Badge Assignment', directory_path: 'badge_test')
    create_list(:participant, 3)
    create_list(:assignment_team, 2)
    create(:team_user, user: User.find(2), team: AssignmentTeam.first)
    create(:team_user, user: User.find(3), team: AssignmentTeam.second)
    create(:team_user, user: User.find(4), team: AssignmentTeam.second)
    # create(:assignment_node)
    # create(:team_user, user: User.where(role_id: 2).first)
    # create(:team_user, user: User.where(role_id: 2).second)
    # create(:assignment_team)
    # create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    # create(:signed_up_team)
    # create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    # create(:assignment_questionnaire)
    # create(:question)
    # # create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
    # # create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)

    Badge.create(name: 'Good Reviewer',
                 description: 'This badge is awarded to students who receive very high review grades.',
                 image_name: 'Badge-Good-Reviewer.png')

    Badge.create(name: 'Good Teammate',
                 description: 'This badge is awarded to students who receive very high teammate review scores.',
                 image_name: 'Badge-Good-Teammate.png')

    AssignmentBadge.create(assignment_id: 1, badge_id: 1, threshold: 95)

    AssignmentBadge.create(assignment_id: 1, badge_id: 2, threshold: 95)

    puts "\n\nAssignment Badges:\n\n"
    assignment_badges = AssignmentBadge.all
    assignment_badges.each do |assignment_badge|
      puts "\t----------"
      puts "\tASSIGNMENT ID: #{assignment_badge.assignment_id}"
      puts "\tBADGE ID: #{assignment_badge.badge_id}"
      puts "\tTHRESHOLD: #{assignment_badge.threshold}"
    end
    puts "\t----------"

    puts "\nUsers:\n\n"
    users = User.all
    users.each do |user|
      puts"\t----------"
      puts "\tUSER ID: #{user.id}"
      puts "\tUSER NAME: #{user.name}"
    end
    puts "\t----------"

    puts "\nParticipants:\n\n"
    participants = Participant.all
    participants.each do |participant|
      puts"\t----------"
      puts "\tPARTICIPANT ID: #{participant.id}"
      puts "\tPARENT ID: #{participant.parent_id}"
      puts "\tUSER ID: #{participant.user_id}"
      puts "\tTYPE: #{participant.type}"
    end
    puts "\t----------"

    puts "\nTeams:\n\n"
    teams = Team.all
    teams.each do |team|
      puts"\t----------"
      puts "\tTEAM ID: #{team.id}"
      puts "\tTEAM NAME: #{team.name}"
      puts "\tTEAM TYPE: #{team.type}"
      puts "\tPARENT ID: #{team.parent_id}"
    end
    puts "\t----------"

    puts "\nTeam Users:\n\n"
    team_users = TeamsUser.all
    team_users.each do |team_user|
      puts"\t----------"
      puts "\tTEAM ID: #{team_user.team_id}"
      puts "\tTEAM NAME: #{Team.find(team_user.team_id).name}"
      puts "\tUSER ID: #{team_user.user_id}"
      puts "\tUSER NAME: #{User.find(team_user.user_id).name}"
    end
    puts "\t----------"

    # WE NEED SOME WAY TO ADD THESE TO THE ASSIGNMENTS:
    # PARTICIPANTS,
    # TEAMS,
    # REVIEW SCORES,
    # TEAMMATE REVIEW SCORES <-- * this may not have a factory method

    # IF WE CAN DO THAT, WE MAY BE ABLE TO "LOG IN" AS THE INSTRUCTOR
    # IN ORDER TO ALTER THE REVIEW SCORES FOR THE TESTS

    # WE ALSO MAY BE ABLE TO "LOG IN" AS THE PARTICIPANTS
    # IN ORDER TO ALTER THE TEAMMATE REVIEWS FOR THE TESTS

    # THERE MAY BE SOME OTHER (BETTER) WAY TO TEST THIS, I AM NOT SURE

    # **********

    # Ok, so the factories are making a little more sense to me.

    # Check out the following methods in the factories.rb file:

    # :student
    # :course
    # :assignment
    # :assignment_team
    # :team_user
    # :participant
    # :review_grade

    # I think we will need to write one for a TeammateReviewReponseMap, maybe?

  end

  it "should appear on the instructor's participant list when threshold is set below score" do

  end

  # it "should appear on the student's task list when threshold is set below score" do
  #
  # end
  #
  # it "should appear on the instructor's participant list when score is set above threshold" do
  #
  # end
  #
  # it "should appear on the student's task list when score is set above threshold" do
  #
  # end

end

describe 'Good Reviewer Badge Absence' do

  it "should not appear on the instructor's participant list when threshold is set above score" do

  end

  it "should not appear on the student's task list when threshold is set above score" do

  end

  it "should not appear on the instructor's participant list when score is set below threshold" do

  end

  it "should not appear on the student's task list when score is set below threshold" do

  end

end

describe 'Good Teammate Badge Presence' do

  it "should appear on the instructor's participant list when threshold is set below score" do

  end

  it "should appear on the student's task list when threshold is set below score" do

  end

  it "should appear on the instructor's participant list when score is set above threshold" do

  end

  it "should appear on the student's task list when score is set above threshold" do

  end

end

describe 'Good Teammate Badge Absence' do

  it "should not appear on the instructor's participant list when threshold is set above score" do

  end

  it "should not appear on the student's task list when threshold is set above score" do

  end

  it "should not appear on the instructor's participant list when score is set below threshold" do

  end

  it "should not appear on the student's task list when score is set below threshold" do

  end

end

# describe "Good Teammate Badge" do
#   it "should assign a badge to student" do
#     login_and_go_to_badge("instructor6",@assignment.id)
#     change_good_teammate_badge_threshold(90)
#     visit "/participants/list?id#{@assignment.id}&model=Assignment"
#     page.all('table#plist td.exp').each |td|
#         expect(td) to have_css('img', text: "Badge-Good-Teammate.png")
#   end
#
# end

