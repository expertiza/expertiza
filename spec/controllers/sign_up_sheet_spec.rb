require 'rails_helper'
include LogInHelper

describe SignUpSheetController do
  before(:each) do
    instructor.save
    @user = User.find_by_name("instructor")

    @wiki = WikiType.new({"name"=>"No"})
    @wiki.save

    @assignment = Assignment.where(name: 'My assignment').first || Assignment.new({
                                                                                  "name"=>"My assignment",
                                                                                  "instructor_id"=>@user.id,
                                                                                  "wiki_type_id"=>@wiki.id
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
    ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
    ApplicationController.any_instance.stub(:undo_link).and_return(TRUE)
  end

  it "should be able to create topic for assignment" do
    get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
    expect(response).should redirect_to(edit_assignment_path(@assignment.id) + "#tabs-5")
  end

  it "should be able to edit topic" do
    get :edit, id: @topic1.id
    expect(response).to be_success
  end

  it "should be able to delete topic" do
    delete :destroy, id: @topic1.id, assignment_id: @assignment.id
    expect(response).should redirect_to edit_assignment_path(@assignment.id) + "#tabs-5"
  end

  #it "should be able to generate topic dependency" do
  #  post :save_topic_dependencies, assignment_id: @assignment.id
  #  expect(File).to exist("public/assets/staggered_deadline_assignment_graph/graph_#{@assignment.id}.jpg")
  #end

  it "should be able to detect cycles" do
    post :save_topic_dependencies, assignment_id: @assignment.id,
         ('topic_dependencies_' + @topic1.id.to_s)=>{"dependent_on"=>[@topic2.id.to_s]},
         ('topic_dependencies_' + @topic2.id.to_s)=>{"dependent_on"=>[@topic1.id.to_s]}
    expect(flash[:error]).to eq("There may be one or more cycles in the dependencies. Please correct them")
  end
end