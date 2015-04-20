require 'rails_helper'

describe SignUpSheetController do
  before(:each) do
    @assignment = Assignment.where(name: 'assignment1').first || Assignment.new({
                                                                                  "id"=> "1",
                                                                                  "name"=>"My assignment",
                                                                                  "is_intelligent"=>1
                                                                              })
    @assignment.save

    @topic = SignUpTopic.new({
                                 topic_name: "Normal Topic",
                                 id: 1,
                                 assignment_id: nil
                             })
    @topic.save

    # simulate authorized session
    ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
    ApplicationController.any_instance.stub(:undo_link).and_return(TRUE)
  end

  it "should be able to create topic for assignment" do
    get :new, id: 1
    expect(response).to be_success
    get :create, id: 1, topic: {topic_name: "New Topic", max_choosers: 2, topic_identifier: "Ch1", category: "Programming"}
    expect(response).should redirect_to(edit_assignment_path(1) + "#tabs-5")
  end

  it "should be able to edit topic" do
    get :edit, id: 1
    expect(response).to be_success
  end

  it "should be able to delete topic" do
    delete :destroy, id: 1, assignment_id: 1
    expect(response).should redirect_to edit_assignment_path(1) + "#tabs-5"
  end
end