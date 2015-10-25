require File.dirname(__FILE__) + '/../test_helper'
require 'team'

class TeamTest < ActiveSupport::TestCase


  test "generate_teamname_series" do

    #simple test
    team = Team.new()
    team.name = Team.generate_team_name("hello")
    team.save
    assert_equal "hello_Team1",team.name

    #test simple increment to 2
    teamName = Team.generate_team_name("hello")
    assert_equal "hello_Team2",teamName

    #regenerate same team name that wasn't saved
    team = Team.new()
    team.name = Team.generate_team_name("hello")
    team.save
    assert_equal "hello_Team2",team.name

    #increment to 3
    teamName = Team.generate_team_name('hello')
    assert_equal "hello_Team3",teamName

    #generate name with string len=0
    teamName = Team.generate_team_name('')
    assert_equal "_Team1",teamName

    #generate name with nil string
    teamName = Team.generate_team_name(nil.to_s)
    assert_equal "_Team1",teamName

    #generate 21st teamName
    21.times do
      team = Team.new()
      team.name = Team.generate_team_name("loop")
      team.save
    end
    assert_equal "loop_Team21",team.name
  end

end