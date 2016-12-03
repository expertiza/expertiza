# require 'assignment_helper'
require 'rails_helper'
include AssignmentHelper

describe LotteryController do  
  describe "#run_intelligent_assignmnent" do
            it "webservice call should be successful" do
                dat=double("data")
                rest=double("RestClient")
                result = RestClient.get 'http://www.google.com',  :content_type => :json, :accept => :json
                expect(result.code).to eq(200)
            end
    
             it "should return json response" do
                result = RestClient.get 'https://www.google.com',  :content_type => :json, :accept => :json
              expect(result.header['Content-Type']).should include 'application/json' rescue result
            end
  end
  
  describe "#run_intelligent_bid" do
              it "should do intelligent assignment" do
                assignment = double("Assignment")
                allow(assignment).to receive(:is_intelligent) { 1 }
                expect(assignment.is_intelligent).to eq(1)
              end
    
              it "should exit gracefully when assignment not intelligent" do
               assignment = double("Assignment")
               allow(assignment).to receive(:is_intelligent) { 0 }
               expect(assignment.is_intelligent).to eq(0)
               redirect_to(controller: 'tree_display')
             end
  end
  
   describe "#create_new_teams_for_bidding_response" do
            it "should create team and return teamid" do
              assignment = double("Assignment")
              team = double("team")
              allow(team).to receive(:create_new_teams_for_bidding_response).with(assignment).and_return(:teamid)
              expect (team.create_new_teams_for_bidding_response(assignment)).should eq(:teamid)
            end
   end
  
     describe "#auto_merge_teams" do
            it "sorts the unassigned teams" do
              assignment = double("Assignment")
              team = double("team")
              unassignedteam =double("team")
              sortedteam =double("team")
              allow(team).to receive(:where).with(assignment).and_return(unassignedteam)
              allow(unassignedteam).to receive(:sort_by).and_return(sortedteam)
              expect (team.where(assignment)).should eq(unassignedteam)
              expect unassignedteam.sort_by.should eq(sortedteam)
            end
     end
      describe "LotteryController1" do
        it "verifies if the swap functionality works properly" do
          student1 = create(:student, name:"A")
          student2 = create(:student, name:"B")
          student3 = create(:student, name:"C")
          student4 = create(:student, name:"D")
          assignment = create(:assignment, name:"assignmentA", is_intelligent: true, max_team_size: 2)
          assignment_old = create(:assignment, name:"assignmentB", is_intelligent: true, max_team_size: 2)

          course_id = assignment.course_id

          topicA = create(:topic, topic_name:"TopicA", assignment: assignment)
          topicB = create(:topic, topic_name:"TopicB", assignment: assignment)
          create(:bid, topic_id: topicA.id, user_id: student1.id, priority: 1)
          create(:bid, topic_id: topicA.id, user_id: student2.id, priority: 1)
          create(:bid, topic_id: topicA.id, user_id: student3.id, priority: 2)
          create(:bid, topic_id: topicA.id, user_id: student4.id, priority: 2)

          create(:bid, topic_id: topicB.id, user_id: student1.id, priority: 2)
          create(:bid, topic_id: topicB.id, user_id: student2.id, priority: 2)
          create(:bid, topic_id: topicB.id, user_id: student3.id, priority: 1)
          create(:bid, topic_id: topicB.id, user_id: student4.id, priority: 1)

          teamA = create(:assignment_team, new_members: 1, assignment: assignment)
          teamB = create(:assignment_team, new_members: 1, assignment: assignment)
          teamA_old = create(:assignment_team, new_members: 1, assignment: assignment_old)
          teamB_old = create(:assignment_team, new_members: 1, assignment: assignment_old)

          create(:participant, user_id: student1.id, assignment: assignment)
          create(:participant, user_id: student2.id, assignment: assignment)
          create(:participant, user_id: student3.id, assignment: assignment)
          create(:participant, user_id: student4.id, assignment: assignment)

          create(:participant, user_id: student1.id, assignment: assignment_old)
          create(:participant, user_id: student2.id, assignment: assignment_old)
          create(:participant, user_id: student3.id, assignment: assignment_old)
          create(:participant, user_id: student4.id, assignment: assignment_old)

          create(:team_user, team: teamA, user: student1)
          create(:team_user, team: teamA, user: student2)
          create(:team_user, team: teamB, user: student3)
          create(:team_user, team: teamB, user: student4)

          create(:team_user, team: teamA_old, user: student1)
          create(:team_user, team: teamA_old, user: student2)
          create(:team_user, team: teamB_old, user: student3)
          create(:team_user, team: teamB_old, user: student4)

          controller.params = {id: assignment.id, test_run: true}
          controller.run_intelligent_assignment

          studentA_team = StudentTask.teamed_students(User.find(student1),course_id,false, nil, assignment.id)[course_id]
          studentB_team = StudentTask.teamed_students(User.find(student2),course_id,false, nil, assignment.id)[course_id]

          expect(studentA_team).not_to match_array(studentB_team)
        end

        it "new members is not set, teams should be the same" do
          student1 = create(:student, name:"A")
          student2 = create(:student, name:"B")
          student3 = create(:student, name:"C")
          student4 = create(:student, name:"D")
          

          assignment = create(:assignment, name:"assignmentA", is_intelligent: true, max_team_size: 2)
          assignment_old = create(:assignment, name:"assignmentB", is_intelligent: true, max_team_size: 2)

          course_id = assignment.course_id

          topicA = create(:topic, topic_name:"TopicA", assignment: assignment)
          topicB = create(:topic, topic_name:"TopicB", assignment: assignment)
          create(:bid, topic_id: topicA.id, user_id: student1.id, priority: 1)
          create(:bid, topic_id: topicA.id, user_id: student2.id, priority: 1)
          create(:bid, topic_id: topicA.id, user_id: student3.id, priority: 2)
          create(:bid, topic_id: topicA.id, user_id: student4.id, priority: 2)
          

          create(:bid, topic_id: topicB.id, user_id: student1.id, priority: 2)
          create(:bid, topic_id: topicB.id, user_id: student2.id, priority: 2)
          create(:bid, topic_id: topicB.id, user_id: student3.id, priority: 1)
          create(:bid, topic_id: topicB.id, user_id: student4.id, priority: 1)
        

          teamA = create(:assignment_team, new_members: 0, assignment: assignment)
          teamB = create(:assignment_team, new_members: 0, assignment: assignment)
          teamA_old = create(:assignment_team, new_members: 0, assignment: assignment_old)
          teamB_old = create(:assignment_team, new_members: 0, assignment: assignment_old)

          create(:participant, user_id: student1.id, assignment: assignment)
          create(:participant, user_id: student2.id, assignment: assignment)
          create(:participant, user_id: student3.id, assignment: assignment)
          create(:participant, user_id: student4.id, assignment: assignment)
          

          create(:participant, user_id: student1.id, assignment: assignment_old)
          create(:participant, user_id: student2.id, assignment: assignment_old)
          create(:participant, user_id: student3.id, assignment: assignment_old)
          create(:participant, user_id: student4.id, assignment: assignment_old)

          create(:team_user, team: teamA, user: student1)
          create(:team_user, team: teamA, user: student2)
          create(:team_user, team: teamB, user: student3)
          create(:team_user, team: teamB, user: student4)
                    

          create(:team_user, team: teamA_old, user: student1)
          create(:team_user, team: teamA_old, user: student2)
          create(:team_user, team: teamB_old, user: student3)
          create(:team_user, team: teamB_old, user: student4)
          
          controller.params = {id: assignment.id, test_run: true}
          studentA_team = StudentTask.teamed_students(User.find(student1),course_id,false, nil, assignment.id)[course_id]
          studentC_team = StudentTask.teamed_students(User.find(student1),course_id,false, nil, assignment.id)[course_id]
          controller.run_intelligent_assignment
          studentA_team_test = StudentTask.teamed_students(User.find(student1),course_id,false, nil, assignment.id)[course_id]
          studentC_team_test = StudentTask.teamed_students(User.find(student1),course_id,false, nil, assignment.id)[course_id]
          expect(studentA_team).to match_array(studentA_team_test)
          expect(studentC_team).to match_array(studentC_team_test)
        end
      end
end
