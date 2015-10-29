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
    it "should not redirect to student_task controller if current user is an instructor" do
      allow(session[:user]).to receive("student?").and_return(false)
      post "list"
      response.should_not redirect_to(list_student_task_index_path)
    end
    it "should redirect to student_task controller if current user is a student" do
      allow(session[:user]).to receive("student?").and_return(true)
       post "list"
       response.should redirect_to(list_student_task_index_path)
    end
  end
  describe "#ta_for_current_mappings?" do
    it "should return true if current user is a TA for current course" do
    end
  end
  describe "#populate_rows" do
    let(:dbl) { double }
    before { expect(dbl).to receive(:populate_rows).with(Hash, String)}
    it "passes when the arguments match" do
      dbl.populate_rows({},"")
    end
  end
  describe "#populate_1_row" do
    let(:dbl) { double }
    before { expect(dbl).to receive(:populate_1_row).with(Node) }
    it "passes when the arguments match" do
      dbl.populate_1_row(Node.new)
    end
  end
end
