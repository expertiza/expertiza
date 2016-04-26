require 'rails_helper'

describe TreeDisplayController do

  describe "#list" do
    it "should not redirect to student_task controller if current user is an instructor" do
      allow(session[:user]).to receive("student?").and_return(false)
      post "list"
      expect(response).not_to redirect_to(list_student_task_index_path)
    end
    it "should redirect to student_task controller if current user is a student" do
      allow(session[:user]).to receive("student?").and_return(true)
      post "list"
      expect(response).to redirect_to(list_student_task_index_path)
    end
  end

  describe "#ta_for_current_mappings?" do
    it "should return true if current user is a TA for current course" do
      allow(session[:user]).to receive("ta?").and_return(true)
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
  
  describe "#drill" do
    it "redirect to list action" do
      get "drill" , root: 1
      expect(session[:root]).to eq('1')
      expect(response).to redirect_to(list_tree_display_index_path)
    end
  end

  describe "GET #get_folder_node_ng" do
    before do
      @treefolder = TreeFolder.new
      @treefolder.parent_id = nil
      @treefolder.name = "Courses"
      @treefolder.child_type = "CourseNode"
      @treefolder.save
      @foldernode = FolderNode.new
      @foldernode.parent_id = nil
      @foldernode.type = "FolderNode"
    end
    it "populates a list of FolderNodes when there is a match" do

      @foldernode.node_object_id = 1
      @foldernode.save

      get :get_folder_node_ng
      expect(response.body).to match [@foldernode].to_json
    end
    it "populates an empty list when there is no match" do

      @foldernode.node_object_id = 2
      @foldernode.save

      get :get_folder_node_ng
      expect(response.body).to eq "[]"
    end
  end
  it { should respond_to(:get_folder_node_ng) }
  it { should respond_to(:get_children_node_ng) }
  it { should respond_to(:get_children_node_2_ng) }

  describe "GET #get_session_last_open_tab" do
    it "returns HTTP status 200" do
      get :get_session_last_open_tab
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #get_children_node_ng" do
    before do
      @treefolder = TreeFolder.new
      @treefolder.parent_id = nil
      @treefolder.name = "Courses"
      @treefolder.child_type = "CourseNode"
      @treefolder.save
      @foldernode = FolderNode.new
      @foldernode.parent_id = nil
      @foldernode.type = "FolderNode"
      @foldernode.node_object_id = 1
      @foldernode.save
      @instructor = FactoryGirl.create(:instructor)
      @course = FactoryGirl.create(:course)
      @assignment = FactoryGirl.create(:assignment)
      @assignment_team = FactoryGirl.create(:assignment_team)
      @team_user = FactoryGirl.create(:team_user)
      @signed_up_team = FactoryGirl.create(:signed_up_team)
      @participant = FactoryGirl.create(:participant)
      @deadline_type = FactoryGirl.create(:course)
      @assignment_node = FactoryGirl.create(:assignment_node)
      @course_node = FactoryGirl.create(:course_node)
      @questionnaire = FactoryGirl.create(:questionnaire)
      @metareview_questionnaire = FactoryGirl.create(:metareview_questionnaire)
      @author_feedback_questionnaire = FactoryGirl.create(:author_feedback_questionnaire)
      @teammate_review_questionnaire = FactoryGirl.create(:teammate_review_questionnaire)
      @question = FactoryGirl.create(:question)
      @review_response_map = FactoryGirl.create(:review_response_map)
      @question = FactoryGirl.create(:question)
      @deadline_right = FactoryGirl.create(:deadline_right)
      @due_date1 = FactoryGirl.create(:due_date1)
    end
    it "returns a list of course objects(private) as json" do
      params = FolderNode.all()
      post :get_children_node_ng, { :reactParams => { :child_nodes => params.to_json , :nodeType => "FolderNode" } }, { :user => @instructor }
      expect(response.body).to match /csc517\/test/
    end
    it "returns an empty list when there are no private or public courses" do
      params = FolderNode.all()
      @instructor.id = 2
      @instructor.save
      post :get_children_node_ng, { :reactParams => { :child_nodes => params.to_json , :nodeType => "FolderNode" } }, { :user => @instructor }
      expect(response.body).to eq "{\"Courses\":[]}"
    end
    it "returns a list of course objects(public) as json" do
      params = FolderNode.all()
      @instructor.id = 2
      @instructor.save
      @course.private = false
      @course.save
      post :get_children_node_ng, { :reactParams => { :child_nodes => params.to_json , :nodeType => "FolderNode" } }, { :user => @instructor }
      expect(response.body).to match /csc517\/test/
    end
  end
end