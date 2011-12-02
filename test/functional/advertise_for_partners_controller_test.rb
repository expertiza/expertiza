#require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
#require 'join_team_requests_controller'

class JoinTeamRequestsControllerTest < ActionController::TestCase
  fixtures :join_team_requests

  def setup
    @team_advertisement_for_partner = Team.new(
      :id => 1, :name => "test team", :parent_id => 2, :type => "AssignmentTeam", :comments_for_advertisement => "", :advertise_for_partner=>true
    )
    @team_advertisement_for_partner.save
  end
  def test_new
    @team_advertisement_for_partner = Team.new(
      :id => 1, :name => "test team", :parent_id => 2, :type => "AssignmentTeam", :comments_for_advertisement => "", :advertise_for_partner=>true
    )
    @team_advertisement_for_partner.save
    assert_not_nil(@team_advertisement_for_partner)
    #@team_advertisement_for_partner.advertise_for_partner = true
    #@team_advertisement_for_partner.comments_for_advertisement = "Me in!!!"
    #@team_advertisement_for_partner.save
    #assert_equal("Me in!!!",Team.find(1).comments_for_advertisement)
    #assert_not_nil(Team.find(1))
  end
  def test_edit
    @team_advertisement_for_partner = Team.new(
      :id => 1, :name => "test team", :parent_id => 2, :type => "AssignmentTeam", :comments_for_advertisement => "", :advertise_for_partner=>true
    )
    @team_advertisement_for_partner.comments_for_advertisement="Greater Good!"
    @team_advertisement_for_partner.save
    assert_response :success
  end


end
