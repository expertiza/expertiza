require 'rails_helper'
include LogInHelper

describe SignUpSheetController do
  before(:each) do
    instructor.save
    @user = User.find_by_name("instructor")

    @assignment = Assignment.where(name: 'My assignment').first || Assignment.new("name" => "My assignment",
                                                                                  "instructor_id" => @user.id)
    @assignment.save

    @topic1 = SignUpTopic.new(topic_name: "Topic1",
                              topic_identifier: "Ch10",
                              assignment_id: @assignment.id,
                              max_choosers: 2)
    @topic1.save

    @topic2 = SignUpTopic.new(topic_name: "Topic2",
                              topic_identifier: "Ch10",
                              assignment_id: @assignment.id,
                              max_choosers: 2)
    @topic2.save

    # simulate authorized session
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return('Instructor')
    allow_any_instance_of(ApplicationController).to receive(:undo_link).and_return(TRUE)
  end

  describe '#create' do
    it "is able to create topic for assignment" do
      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(edit_assignment_path(@assignment.id) + "#tabs-5")
    end

    it "is able to update a topic for assignment that already has max choosers set" do
      sign_up_topic = SignUpTopic.new
      sign_up_topic.max_choosers = 2
      allow(SignUpTopic).to receive_message_chain(:where, :first).with(any_args) { sign_up_topic }

      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to(action: 'add_signup_topics', id: @assignment.id))
    end

    it "is able to update a topic for assignment that needs the waitlisted users updated" do
      sign_up_topic = SignUpTopic.new
      sign_up_topic.max_choosers = 0
      allow(SignUpTopic).to receive_message_chain(:where, :first).with(any_args) { sign_up_topic }

      allow(SignedUpTeam).to receive(:find_by_topic_id) { SignedUpTeam.new }
      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to(action: 'add_signup_topics', id: @assignment.id))
    end

    it "is able to update a topic for assignment but warn when max_choosers is too much" do
      sign_up_topic = SignUpTopic.new
      sign_up_topic.max_choosers = 4
      allow(SignUpTopic).to receive_message_chain(:where, :first).with(any_args) { sign_up_topic }

      allow(SignedUpTeam).to receive(:find_by_topic_id) { SignedUpTeam.new }

      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to(action: 'add_signup_topics', id: @assignment.id))
      expect(flash[:error]).to eq('The value of the maximum number of choosers can only be increased! No change has been made to maximum choosers.')
  end

    it "is able to update a topic with a microtask" do
      @assignment.microtask = true
      @assignment.save
      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(edit_assignment_path(@assignment.id) + "#tabs-5")
    end

    it "is able to update a topic with staggard deadlines" do
      @assignment.staggered_deadline = true
      @assignment.save
      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(edit_assignment_path(@assignment.id) + "#tabs-5")
    end

    it "will fail gracefully when a topic cannot be saved" do
      get :create, id: @assignment.id, topic: {topic_name: "New Topic", topic_identifier: "Ch1", category: "Programming"}
      expect(response).to render_template("sign_up_sheet/new")
    end
  end

  it "is able to edit topic" do
    get :edit, id: @topic1.id
    expect(response).to be_success
  end

  it "is able to delete topic" do
    delete :destroy, id: @topic1.id, assignment_id: @assignment.id
    expect(response).to redirect_to edit_assignment_path(@assignment.id) + "#tabs-5"
  end

  xdescribe "Save topic deadlines" do
    it "redirects to edit assignment page" do
      session[:duedates] = [@topic1, @topic2]
      assignment = double(Assignment)
      allow(assignment).to receive(:num_review_rounds) { 0 }
      allow(SignUpTopic).to receive("where").and_return([])
      post :save_topic_deadlines, due_date: NIL, assignment_id:                                     @assignment.id
      expect(response).to redirect_to edit_assignment_url(id:                                                                @assignment.id)
    end

    it "saves deadlines for topics with staggered deadlines" do
      session[:duedates] = [@topic1, @topic2]
      assignment = double(Assignment)
      allow(assignment).to receive(:num_review_rounds) { 0 }
      allow(SignUpTopic).to receive("where").and_return([@topic1])
      topic_duedate = TopicDueDate.new
      allow(TopicDueDate).to receive(:where) { topic_duedate }
      allow(topic_duedate).to receive(:update_attributes)
      allow(topic_duedate).to receive(:first) { topic_duedate }

      deadline_type = DeadlineType.new
      deadline_type.id = 0
      allow(DeadlineType).to receive(:where) { deadline_type }

      post :save_topic_deadlines, due_date:                                        "15_submission_1_due_date", assignment_id: @assignment.id
      expect(response).to redirect_to edit_assignment_url(id:                                                                @assignment.id)
    end

    it "updates deadline for topics for multiple review rounds" do
      session[:duedates] = [@topic1, @topic2]

      assignment = double(Assignment)
      allow(Assignment).to receive(:find) { assignment }
      allow(assignment).to receive(:num_review_rounds).and_return(2)

      allow(SignUpTopic).to receive("where").and_return([@topic1])

      deadline_type = DeadlineType.new
      deadline_type.id = 0
      allow(deadline_type).to receive(:first) { deadline_type }
      allow(deadline_type).to receive(:update_attributes)
      allow(deadline_type).to receive(:first) { deadline_type }

      topic_duedate = TopicDueDate.new
      allow(TopicDueDate).to receive(:where) { topic_duedate }
      allow(topic_duedate).to receive(:update_attributes)
      allow(topic_duedate).to receive(:first) { topic_duedate }
      allow(DeadlineType).to receive(:where) { topic_duedate }

      post :save_topic_deadlines, due_date: "15_submission_1_due_date", assignment_id: @assignment.id
      expect(response).to redirect_to edit_assignment_url(id: @assignment.id)
    end
  end
end

describe SignUpSheetController do
  before(:each) do
    @assignment = create(:assignment)
    create_list(:participant, 3)
    @student1 = User.where(role_id: 2).first
    @student2 = User.where(role_id: 2).second
    @student3 = User.where(role_id: 2).third

    @topic1 = create(:topic, topic_name: "Parallel Architecture")
    @topic2 = create(:topic, topic_name: "MVC Framework")
    @topic3 = create(:topic, topic_name: "Design Patterns")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic") # Must Have an ID of 6
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "drop_topic").first, due_at: DateTime.now.in_time_zone - 1.day)

    create(:assignment_team, name: "Team1")
    create(:assignment_team, name: "Team2")
    create(:assignment_team, name: "Team3", submitted_hyperlinks: nil)
    create(:team_user, user: User.where(role_id: 2).first, team: AssignmentTeam.first)
    create(:team_user, user: User.where(role_id: 2).second, team: AssignmentTeam.second)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.third)

    create(:signed_up_team, team_id: 2 , topic: SignUpTopic.second)
    create(:signed_up_team, team_id: 3 , topic: SignUpTopic.third)

    # Simulate Authorized Session
    instructor.save
    @user = User.find_by_name("instructor")
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return('Instructor')
    allow_any_instance_of(ApplicationController).to receive(:undo_link).and_return(TRUE)
  end

  describe "Instructor singup user" do
    it "adds user to topic with no signed up team" do
      post :signup_as_instructor_action, username: @student1.name, assignment_id: @assignment.id, topic_id: @topic1.id
      expect(flash[:success]).to eq('You have successfully signed up the student for the topic!')
    end
    it "checks that a user already has a topic" do
      post :signup_as_instructor_action, username: @student2.name, assignment_id: @assignment.id, topic_id: @topic1.id
      expect(flash[:error]).to eq('The student has already signed up for a topic!')
    end
    it "checks to make sure the user exists" do
      post :signup_as_instructor_action, username: "asifljasdlf", assignment_id: @assignment.id, topic_id: @topic1.id
      expect(flash[:error]).to eq('That student does not exist!')
    end
    it "redirects back to topics page" do
      post :signup_as_instructor_action, username: @student1.name, assignment_id: @assignment.id, topic_id: @topic1.id
      expect(response).to redirect_to edit_assignment_url(id: @assignment.id)
    end
  end

  describe "Instructor delete signup" do
    it "checks to see if the user has already submitted their work" do
      post :delete_signup_as_instructor, id: 2, topic_id: @topic2.id
      expect(flash[:error]).to eq('The student has already submitted their work, so you are not allowed to remove them.')
    end
    it "checks to see if the deadline has passed" do
      post :delete_signup_as_instructor, id: 3, topic_id: @topic3.id
      expect(flash[:error]).to eq('You cannot drop a student after the drop topic deadline!')
    end
    it "redirects back to topics page" do
      post :delete_signup_as_instructor, id: 3, topic_id: @topic3.id
      expect(response).to redirect_to edit_assignment_url(id: @assignment.id)
    end
  end
end
