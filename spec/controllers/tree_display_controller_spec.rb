require 'rails_helper'

describe TreeDisplayController do
  # Airbrake-1517247902792549741
  describe "#list" do
    it "should not redirect to tree_display#list if current user is an instructor" do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).not_to redirect_to('/tree_display/list')
    end

    it "should redirect to student_task#list if current user is a student" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to redirect_to('/student_task/list')
    end

    it "should redirect to login page if current user is nil" do
      get "list"
      expect(response).to redirect_to('/auth/failure')
    end
  end

  describe "#confirm_notifications_access" do
    it "should verify usertype" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "confirm_notifications_access"
      expect(response).to redirect_to('/notifications/list')
    end
  end

  describe "#ta_for_current_mappings?" do
    it "should return true if current user is a TA for current course" do
      allow(session[:user]).to receive("ta?").and_return(true)
    end
  end

  describe "#populate_rows" do
    let(:dbl) { double }
    before { expect(dbl).to receive(:populate_rows).with(Hash, String) }
    it "passes when the arguments match" do
      dbl.populate_rows({}, "")
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
      get "drill", root: 1
      expect(session[:root]).to eq('1')
      expect(response).to redirect_to(list_tree_display_index_path)
    end
  end

  describe "GET #folder_node_ng_getter" do
    before(:each) do
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
      get :folder_node_ng_getter
      expect(response.body).to match [@foldernode].to_json
    end
    it "populates an empty list when there is no match" do
      @foldernode.node_object_id = 2
      @foldernode.save
      get :folder_node_ng_getter
      expect(response.body).to eq "[]"
    end
  end
  it { is_expected.to respond_to(:folder_node_ng_getter) }
  it { is_expected.to respond_to(:children_node_ng) }
  it { is_expected.to respond_to(:children_node_2_ng) }

  describe "GET #session_last_open_tab" do
    it "returns HTTP status 200" do
      get :session_last_open_tab
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #children_node_ng" do
    before(:each) do
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
      @course = create(:course)
      create(:assignment)
      create(:assignment_node)
      create(:course_node)
      @instructor = User.where(role_id: 1).first
    end

    it "returns a list of course objects(private) as json" do
      params = FolderNode.all
      post :children_node_ng, {reactParams: {child_nodes: params.to_json, nodeType: "FolderNode"}}, user: @instructor
      expect(response.body).to match /csc517\/test/
    end

    it "returns an empty list when there are no private or public courses" do
      params = FolderNode.all
      Assignment.delete(1)
      Course.delete(1)
      post :children_node_ng, {reactParams: {child_nodes: params.to_json, nodeType: "FolderNode"}}, user: @instructor
      expect(response.body).to eq "{\"Courses\":[]}"
    end

    it "returns a list of course objects(public) as json" do
      params = FolderNode.all
      @course.private = false
      @course.save
      post :children_node_ng, {reactParams: {child_nodes: params.to_json, nodeType: "FolderNode"}}, user: @instructor
      expect(response.body).to match /csc517\/test/
    end
  end
end
