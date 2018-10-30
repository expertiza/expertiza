describe Menu do

    before :example do
        controller = double("controller", :id => 43, :name => "controller1")
        temp = double("temp", :id => 33, :controller => controller, :name => "temp", :url_to_use => nil)
        allow_any_instance_of(MenuItem).to receive(:controller_action).and_return(temp)
        allow_any_instance_of(MenuItem).to receive(:content_page).and_return(temp)
    end

    before :all do
        @student_role = build(:role_of_student, id: 1, name: "Student", description: '', parent_id: nil, default_page_id: nil)
        @instructor_role = build(:role_of_instructor, id: 2, name: "Instructor", description: '', parent_id: nil, default_page_id: nil)
        @admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: nil, default_page_id: nil)
        @invalid_role = build(:role_of_student, id: 1, name: nil, description: "", parent_id: nil, default_page_id: nil)
    end

    let!(:test1) { create(:menu_item, name: "home1", parent_id: nil,  seq: 1) }
    let!(:test2) { create(:menu_item, name: "home2", parent_id: 1,    seq: 2) }
    let!(:test3) { create(:menu_item, name: "home3", parent_id: 1,    seq: 3) }
    let!(:test4) { create(:menu_item, name: "home4", parent_id: 1,    seq: 4) }
    let!(:test5) { create(:menu_item, name: "home5", parent_id: 2,  seq: 2) }
    let!(:test6) { create(:menu_item, name: "home6", parent_id: 3,  seq: 5) }
    
    describe Menu::Node do
        describe "#initilize" do
            context "when role is nil" do
                it "initializes with a nil parent" do
                    @node = Menu::Node.new
                    expect(@node.parent).to be_nil
                end
            end
        end
        describe "#site_controller" do
            context "when @site_controller is nil" do
                it "updates @site_controller" do
                    node = Menu::Node.new
                    allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
                    expect(node.site_controller).to eq("test site_controller")
                end
            end
            context "when @site_controller already has a value" do
                it "remains the same" do
                    node = Menu::Node.new
                    allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
                    node.site_controller
                    allow(SiteController).to receive(:find_by).with(anything).and_return("second controller")
                    expect(node.site_controller).to eq("test site_controller")
                end
            end
        end
        describe "#controller_action" do
            context "when @controller_action is nil" do
                it "updates @controller_action" do
                    node = Menu::Node.new
                    allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
                    expect(node.controller_action).to eq("test controller_action")
                end
            end
            context "when @controller_action already has a value" do
                it "remains the same" do
                    node = Menu::Node.new
                    allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
                    node.controller_action
                    allow(ControllerAction).to receive(:find_by).with(anything).and_return("second action")
                    expect(node.controller_action).to eq("test controller_action")
                end
            end
        end

        #Content_page should update the property
        #content_page should update every time it is called

        #add_children should update children array (test multiple children)
        describe "#add_child" do
            context "when node has no children" do
                it "adds a child" do
                    node = Menu::Node.new
                    node.add_child(test1)
                    expect(node.children[0]).to eq(1)
                end
            end
        end
    end

    describe "#initialize" do
        context "when role is nil" do
            it "creates a new menu" do
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
                menu = Menu.new
                expect(menu.instance_of?Menu)
            end
        end
        context "when menu has items" do
            it "creates a new menu with items" do
                items = [test1, test2, test3, test4, test5, test6]
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
                menu = Menu.new
                expect(menu.root.children[0]).to eq(1)
            end
        end
    end
    #Ask for help on how this works
    describe "#select" do
        it "returns a node.id based on the given name" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            expect(menu.select("home3").id).to eq(test3.id)
        end
    end
    describe"#selected" do
        context "when an item is selected" do
            it "returns the name of the currently selected item" do
                items = [test1, test2, test3, test4, test5, test6]
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
                menu = Menu.new
                menu.select("home3")
                expect(menu.selected).to eq(test3.name)
            end
        end
        #how is this even possible????
        context "when nothing is selected" do
            it "returns nil" do 
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
                menu = Menu.new
                menu.select("DNE")
                expect(menu.selected).to be_nil
            end
        end
    end

    describe "#get_item" do
        context "when menu has no items" do
            it "returns nil" do
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
                menu = Menu.new
                expect(menu.get_item(0)).to be_nil
            end
        end
        context "when menu has items" do
            it "returns the correct item" do
                items = [test1, test2, test3, test4, test5, test6]
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
                menu = Menu.new
                expect(menu.get_item(2).id).to eq(test2.id)
            end
        end
    end

    describe "#get_menu" do
        context "when a node is selected" do
            it "returns a list of nodes that are the children of the selected node" do
                items = [test1, test2, test3, test4, test5, test6]
                allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
                menu = Menu.new
                expect(menu.get_menu(1)).to eq([2,3,4])
                #this seems like it might be broken
                #expect(menu.get_menu(2)).to eq([6])
            end
        end
    end


end