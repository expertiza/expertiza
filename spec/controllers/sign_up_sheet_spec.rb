require 'rails_helper'
include LogInHelper

describe SignUpSheetController do
  before(:each) do
    instructor.save
    @user = User.find_by_name("instructor")

    @assignment = Assignment.where(name: 'My assignment').first || Assignment.new({
                                                                                  "name"=>"My assignment",
                                                                                  "instructor_id"=>@user.id,
                                                                              })
    @assignment.save

    @topic1 = SignUpTopic.new({
                                 topic_name: "Topic1",
                                 topic_identifier: "Ch10",
                                 assignment_id: @assignment.id,
                                 max_choosers: 2
                             })
    @topic1.save

    @topic2 = SignUpTopic.new({
                                  topic_name: "Topic2",
                                  topic_identifier: "Ch10",
                                  assignment_id: @assignment.id,
                                  max_choosers: 2
                              })
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
      allow(SignUpTopic).to receive(:where) { sign_up_topic }
      allow(sign_up_topic).to receive(:first) { sign_up_topic }

      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to :action => 'add_signup_topics', :id => @assignment.id)
    end

    it "is able to update a topic for assignment that needs the waitlisted users updated" do
      sign_up_topic = SignUpTopic.new
      sign_up_topic.max_choosers = 0
      allow(SignUpTopic).to receive(:where) { sign_up_topic }
      allow(sign_up_topic).to receive(:first) { sign_up_topic }

      allow(SignedUpTeam).to receive(:find_by_topic_id) { SignedUpTeam.new }

      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to :action => 'add_signup_topics', :id => @assignment.id)
    end

    it "is able to update a topic for assignment but warn when max_choosers is too much" do
      sign_up_topic = SignUpTopic.new
      sign_up_topic.max_choosers = 4
      allow(SignUpTopic).to receive(:where) { sign_up_topic }
      allow(sign_up_topic).to receive(:first) { sign_up_topic }

      allow(SignedUpTeam).to receive(:find_by_topic_id) { SignedUpTeam.new }

      get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
      expect(response).to redirect_to(redirect_to :action => 'add_signup_topics', :id => @assignment.id)
      expect(flash[:error]).to eq('Value of maximum choosers can only be increased! No change has been made to max choosers.')
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

  #it "is able to generate topic dependency" do
  #  post :save_topic_dependencies, assignment_id: @assignment.id
  #  expect(File).to exist("public/assets/staggered_deadline_assignment_graph/graph_#{@assignment.id}.jpg")
  #end

  it "is able to detect cycles" do
    post :save_topic_dependencies, assignment_id: @assignment.id,
         ('topic_dependencies_' + @topic1.id.to_s)=>{"dependent_on"=>[@topic2.id.to_s]},
         ('topic_dependencies_' + @topic2.id.to_s)=>{"dependent_on"=>[@topic1.id.to_s]}
    expect(flash[:error]).to eq("There may be one or more cycles in the dependencies. Please correct them")
  end

  describe "Save topic deadlines" do

    it "redirects to edit assignment page" do
      session[:duedates] = [@topic1, @topic2]
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { 0 }
      allow(SignUpTopic).to receive("where").and_return([])
      post :save_topic_deadlines, {:due_date => NIL, :assignment_id =>
                                    @assignment.id}
      expect(response).to redirect_to edit_assignment_url({:id =>
                                                               @assignment.id} )
    end

    it "saves deadlines for topics with staggered deadlines" do
      session[:duedates] = [@topic1, @topic2]
      assignment = double(Assignment)
      allow(assignment).to receive(:get_review_rounds) { 0 }
      allow(SignUpTopic).to receive("where").and_return([@topic1])
      topic_deadline_stub = double(TopicDeadline)
      topic_deadline = TopicDeadline.new
      allow(TopicDeadline).to receive(:where) {topic_deadline}
      allow(topic_deadline).to receive(:update_attributes)
      allow(topic_deadline).to receive(:first) {topic_deadline}

      deadline_type = DeadlineType.new
      deadline_type.id = 0
      allow(DeadlineType).to receive(:where) { deadline_type }

      post :save_topic_deadlines, {:due_date =>
                                       "15_submission_1_due_date", :assignment_id => @assignment.id}
      expect(response).to redirect_to edit_assignment_url({:id =>
                                                               @assignment.id} )
    end

    it "updates deadline for topics for multiple review rounds" do
      session[:duedates] = [@topic1, @topic2]

      assignment = double(Assignment)
      allow(Assignment).to receive(:find) {assignment}
      allow(assignment).to receive(:get_review_rounds).and_return(2)

      allow(SignUpTopic).to receive("where").and_return([@topic1])

      deadline_type = DeadlineType.new
      deadline_type.id = 0
      allow(deadline_type).to receive(:first) {deadline_type}
      allow(deadline_type).to receive(:update_attributes)
      allow(deadline_type).to receive(:first) {deadline_type}

      topic_deadline_stub = double(TopicDeadline)
      topic_deadline = TopicDeadline.new
      allow(TopicDeadline).to receive(:where) {topic_deadline}
      allow(topic_deadline).to receive(:update_attributes)
      allow(topic_deadline).to receive(:first) {topic_deadline}
      allow(DeadlineType).to receive(:where) {topic_deadline}

      post :save_topic_deadlines, {:due_date => "15_submission_1_due_date", :assignment_id => @assignment.id}
      expect(response).to redirect_to edit_assignment_url({:id => @assignment.id} )
    end
  end
end
