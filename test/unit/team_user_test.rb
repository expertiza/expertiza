require File.dirname(__FILE__) + '/../test_helper'

class TeamsUserTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :teams
  fixtures :teams_users
  fixtures :nodes

  def test_hello
    assert_equal(teams_users(:lottery_teams_users1).hello,"Hello")
  end

  def test_name
    assert_equal(teams_users(:lottery_teams_users1).name,"student1")
  end

  def test_add_team_user
    team_user = TeamsUser.new
    assert team_user.valid?
  end

  def test_remove_team_user
    assert_difference 'TeamsUser.count', -1, 'remove team user' do
        TeamsUser.remove_team(users(:student1),teams(:lottery_team1))
    end
    #assert_equal(9,TeamsUser.count)
  end

  def test_delete_team
    assert_difference 'TeamsUser.count', -1, 'remove team'  do
        teams_users(:lottery_teams_users4).delete 
    end  
    #assert_equal(9,TeamsUser.count)     
  end

  def  test_first_by_team_id
    assert_equal(teams_users(:lottery_teams_users1).id,TeamsUser.first_by_team_id(teams(:lottery_team1)).id)
  end

  def  test_is_team_empty
    assert(!(TeamsUser.is_team_empty(teams(:lottery_team1).id)))
  end

  def  test_add_member_to_invited_team
    assert(!(TeamsUser.add_member_to_invited_team(users(:student1).id, users(:student4).id, assignments(:lottery_assignment).id)))
  end

end

