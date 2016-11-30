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
      sign_up_topic.max_choosers = 5
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

end

