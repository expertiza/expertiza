require File.dirname(__FILE__) + '/../test_helper'
require 'yaml'
require 'assignment_team'
require 'test_helper'

class AssignmentParticipantTest < ActiveSupport::TestCase
  fixtures :assignments, :users, :roles, :participants , :questionnaires, :assignments , :courses, :teams  , :join_team_requests

  def test_new_add_team
    team = Team.new
    assert team.save
  end
  def test_add_new_team_member
    course = courses(:course0)
    parent = CourseNode.create(:parent_id => nil, :node_object_id => course.id)

    currTeam = CourseTeam.new
    currTeam.name = name
    currTeam.parent_id = course.id
    assert currTeam.save

    TeamNode.create(:parent_id => parent.id, :node_object_id => currTeam.id)


    currTeam.add_member(users(:student1));
    assert currTeam.has_user(users(:student1))
  end
  def test_add_participant()
    participant = Participant.new

    # assert !participant.valid?

    assert participant.valid?
  end
  def test_import
    row = Array.new
    row[0] = "student1"
    row[1] = "student1_fullname"
    row[2] = "student1@foo.edu"
    row[3] = "s1"

    @request    = ActionController::TestRequest.new
    @request.session[:user] = User.find( users(:student1).id )
    roleid = User.find(users(:student1).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)

    id = Assignment.find(assignments(:assignment_team_count).id).id

    pc = AssignmentParticipant.count
    AssignmentParticipant.import(row,@request.session,id)
    # verify that a single user was added to participants table
    assert_equal pc+1,AssignmentParticipant.count
    user = User.find_by_name("student1")
    # verify that correct user was added
    assert AssignmentParticipant.find_by_user_id(user.id)
  end
  def test_scores_view
    questionnaire1 = Array.new
    questionnaire1<<questionnaires(:questionnaire0)
    questionnaire1<<questionnaires(:questionnaire1)
    questionnaire1<<questionnaires(:questionnaire2)
    questionnaire1<<questionnaires(:peer_review_questionnaire)
    scores = Hash.new
    scores[:participant] = AssignmentParticipant.find_by_parent_id(assignments(:assignment0))
    questionnaire1.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(AssignmentParticipant.find_by_parent_id(assignments(:assignment0)))
      assert_not_equal(scores[questionnaire.symbol][:assessments],0)
    end
  end



end
