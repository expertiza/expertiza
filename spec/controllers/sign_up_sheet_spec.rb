require 'rails_helper'

describe SignUpSheetController do
  before(:each) do
    @assignment = Assignment.where(name: 'My assignment').first || Assignment.new({
                                                                                  "name"=>"My assignment",
                                                                                  "instructor_id"=>1
                                                                              })
    @assignment.save

    @topic = SignUpTopic.new({
                                 topic_name: "Normal Topic",
                                 topic_identifier: "Ch10",
                                 assignment_id: @assignment.id,
                                 max_choosers: 2
                             })
    @topic.save

    # simulate authorized session
    ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
    ApplicationController.any_instance.stub(:undo_link).and_return(TRUE)
  end

  it "should be able to create topic for assignment" do
    get :create, id: @assignment.id, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
    expect(response).should redirect_to(edit_assignment_path(@assignment.id) + "#tabs-5")
  end

  it "should be able to edit topic" do
    get :edit, id: @topic.id
    expect(response).to be_success
  end

  it "should be able to delete topic" do
    delete :destroy, id: @topic.id, assignment_id: @assignment.id
    expect(response).should redirect_to edit_assignment_path(@assignment.id) + "#tabs-5"
  end
end