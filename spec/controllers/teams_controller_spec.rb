require 'rails_helper'
include LogInHelper

describe TeamsController do
  before :all do
    instructor.save
    user1.save
    user2.save
    user3.save
    user4.save
    @testuser1=User.find_by_name("user1")
    @testuser2=User.find_by_name("user2")
    @testuser3=User.find_by_name("user3")
    @testuser4=User.find_by_name("user4")
    
    @user = User.find_by_name("instructor")
    @course=Course.new({:name=>"course1"})
    @course.save


    @wiki = WikiType.new({"name"=>"No"})
    @wiki.save

    @assignment = Assignment.new({"name"=>"My assignment","instructor_id"=>@user.id,"course_id"=>@course.id,"wiki_type_id"=>@wiki.id,:max_team_size=>2})
    @assignment.save

    @topic1 = SignUpTopic.new({
                                 topic_name: "Topic1",
                                 topic_identifier: "Ch10",
                                 assignment_id: @assignment.id,
                                 max_choosers: 1
                             })
    @topic1.save

    

    @participant1=Participant.new({:user_id=>@testuser1.id,:parent_id=>@assignment.id})
    @participant1.save
    @participant2=Participant.new({:user_id=>@testuser2.id,:parent_id=>@assignment.id})
    @participant2.save
    @participant3=Participant.new({:user_id=>@testuser3.id,:parent_id=>@assignment.id})
    @participant3.save
    @participant4=Participant.new({:user_id=>@testuser4.id,:parent_id=>@assignment.id})
    @participant4.save

    @team1=Team.new({:name=>"team1",:parent_id=>@assignment.id});
    @team1.save
    @team1_user1=TeamsUser.new({:team_id=>@team1.id,:user_id=>@testuser1.id})
    @team1_user1.save
    @team1_user2=TeamsUser.new({:team_id=>@team1.id,:user_id=>@testuser2.id})
    @team1_user2.save
    @team2=Team.new({:name=>"team2",:parent_id=>@assignment.id});
    @team2.save
    @team2_user1=TeamsUser.new({:team_id=>@team2.id,:user_id=>@testuser3.id})
    @team2_user1.save
    @team2_user2=TeamsUser.new({:team_id=>@team2.id,:user_id=>@testuser4.id})
    @team2_user2.save
    
    
    @sign_up_team1=SignedUpTeam.new({:topic_id=>@topic1.id,:team_id=>@team1.id})
    @sign_up_team1.save

    @sign_up_team2=SignedUpTeam.new({:topic_id=>@topic1.id,:team_id=>@team2.id,:is_waitlisted=>true})
    @sign_up_team2.save  
  end

    it "should test team gets deleted" do
        ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
        ApplicationController.any_instance.stub(:undo_link).and_return(TRUE)
        delete :delete, {id: @team1.id}, {team_type: @assignment.class.to_s}
        Team.count.should eql 1        
    end

    it "should check if next wailisted team got the topic" do
        ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
        ApplicationController.any_instance.stub(:undo_link).and_return(TRUE)  
        @sign_up_team2.is_waitlisted.should eql false
    end

end
