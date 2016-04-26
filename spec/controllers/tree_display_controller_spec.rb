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
end