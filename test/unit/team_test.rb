require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :courses
  fixtures :teams
  
  def test_add_team
    team = Team.new
    assert team.save
  end
  
  def test_add_team_member
    course = courses(:course0)
    parent = CourseNode.create(:parent_id => nil, :node_object_id => course.id)
    
    currTeam = CourseTeam.new
   	currTeam.name = name
   	currTeam.parent_id = course.id
   	assert currTeam.save

   	TeamNode.create(:parent_id => parent.id, :node_object_id => currTeam.id)
   	#TODO assertion missing?

    currTeam.add_member(users(:student1));
    assert currTeam.has_user(users(:student1))
  end
end

