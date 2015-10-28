require 'rails_helper'

describe TreeDisplayController do
  describe "#filter" do
    before do
      @course = Course.new({
                            "id" => "1",
                            "name" => "My course",
                            "instructor_id" => "1"
                          })
      @instructor = User.new({
        "id" => "1",
        "name" => "Instructor",
        "crypted_password" => User.new.reset_password,
        "role_id" => "1",
        "is_new_user" => "1"
      })
      @role = Role.new({
        "id" => "1",
        "name" => "Instructor"
      })
      @questionnaire = Questionnaire.new({
                                          "id" => "1001",
                                          "name" => "My Questionnaire",
                            "instructor_id" => "1"
                                        })
      @assignment_questionnaire = AssignmentQuestionnaire.new({
                                                    "id" => "10001",
                                                    "assignment_id" => "101",
                                                    "questionnaire_id" => "1001",
                            "user_id" => "1"
                                                  })
      if(@instructor.save)
        puts "saved"
      @course.save
      FactoryGirl.create(:assignment).should be_valid
      @questionnaire.save
      @assignment_questionnaire.save
      else
        puts "error"
      end
    end
#    it "filters questionnaire by assignment name" do
 #     expect(TreeDisplayController).should_receive(:filter).with({:filter_string => "My assignment", :filternode => "QAN"}).and_return("filter+1001")
  #    post 'list', :filter_string => "My assignment", :filternode => "QAN"
   # end
#    it "filters assignment by course name" do
 #     TreeDisplayController.new.should_receive(:filter).with("My course", "ACN").and_return("filter+My course")
  #  end
  end
  describe "#get_children_node_ng" do
#    it "should " do
 #     TreeDisplayController.should_receive(:get_children_node_ng).with({:reactParams => {:child_nodes => "data", :nodeType => "FolderNode"}})
  #  end
  end
  describe "#list" do
    before do
      FactoryGirl.create(:student_role).should be_valid
      FactoryGirl.create(:instructor_role).should be_valid
      @student = FactoryGirl.create(:student)
      puts @student.id
      FactoryGirl.create(:instructor).should be_valid
    end
    it "should redirect to student_task controller if current user is a student" do
      #TreeDisplayController.should_receive(:list)
      session[:user] = @student
 #     post 'list'
  #    response.should redirect_to '/student_task/list'
#      expect(:get => "list").to route_to(:method => "get", :controller => "student_task", :action => "list", :page_name => "list")
 #     expect(:get => "list").to redirect_to(list_student_task_index)
      post "list"
      response.code.should == 301
    end
  end
end
