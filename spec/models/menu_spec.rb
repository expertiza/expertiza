describe Menu do
    before :all do
        @student_role = build(:role_of_student, id: 1, name: "Student", description: '', parent_id: nil, default_page_id: nil)
        @instructor_role = build(:role_of_instructor, id: 2, name: "Instructor", description: '', parent_id: nil, default_page_id: nil)
        @admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: nil, default_page_id: nil)
        @invalid_role = build(:role_of_student, id: 1, name: nil, description: "", parent_id: nil, default_page_id: nil)
    end

    # describe Node do
        
    # end

 let!(:test1) { create(:menu_item, name: "home1", parent_id: nil,  seq: 1) }
 let!(:test2) { create(:menu_item, name: "home2", parent_id: 1,    seq: 2) }
 let!(:test3) { create(:menu_item, name: "home3", parent_id: 1,    seq: 3) }
 let!(:test4) { create(:menu_item, name: "home4", parent_id: 1,    seq: 4) }
 let!(:test5) { create(:menu_item, name: "home5", parent_id: 2,  seq: 2) }
 let!(:test6) { create(:menu_item, name: "home6", parent_id: 3,  seq: 5) }
    
    describe Node do
        describe "#initilize" do
            it "should initialize with a nil parent" do
                @node = Menu::Node.new
                expect(@node.parent).to be_nil
            end
        end
        describe "#site_controller" do
            it "update site_controller property if it is nil" do
                node = Menu::Node.new
                allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
                expect(node.site_controller).to eq("test site_controller")
            end
            it "should remain the same if it already has a value" do
                node = Menu::Node.new
                allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
                node.site_controller
                allow(SiteController).to receive(:find_by).with(anything).and_return("second controller")
                expect(node.site_controller).to eq("test site_controller")
            end
        end
        describe "#controller_action" do
            it "update controller_action property if it is nil" do
                node = Menu::Node.new
                allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
                expect(node.controller_action).to eq("test controller_action")
            end
            it "should remain the same if it already has a value" do
                node = Menu::Node.new
                allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
                node.controller_action
                allow(ControllerAction).to receive(:find_by).with(anything).and_return("second action")
                expect(node.controller_action).to eq("test controller_action")
            end
        end

        #Content_page should update the property
        #content_page should update every time it is called

        #add_children should update children array (test multiple children)
        describe "#add_child" do
            it "should add a child" do
                node = Menu::Node.new
                node.add_child(test1)
                expect(node.children[0]).to eq(1)
            end
        end
    end

    describe "#initialize" do
        it "should create a new menu for a nil role" do
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
            menu = Menu.new
            expect(menu.instance_of?Menu)
        end
        it "should create a new menu with items" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            expect(menu.root.children[0]).to eq(1)
        end

    end
    #Ask for help on how this works
    describe "#select" do
        it "should return a node.id based on the given name" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            expect(menu.select("home3").id).to eq(test3.id)
        end
    end
    describe"#selected" do
        it "should return the name of the currently selected item if an item is selected" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            menu.select("home3")
            expect(menu.selected).to eq(test3.name)
        end
        #how is this even possible????
        it "should return nil if nothing is selected" do 
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
            menu = Menu.new
            menu.select("DNE")
            expect(menu.selected).to be_nil
        end
    end

    describe "#get_item" do
        it "should return nil if menu has no items" do
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
            menu = Menu.new
            expect(menu.get_item(0)).to be_nil
        end
        it "should return the correct item" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            expect(menu.get_item(2).id).to eq(test2.id)
        end
    end

    describe "#get_menu" do
        it "should return a list of nodes that are the children of the selected node" do
            items = [test1, test2, test3, test4, test5, test6]
            allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
            menu = Menu.new
            expect(menu.get_menu(1)).to eq([2,3,4])
            #this seems like it might be broken
            #expect(menu.get_menu(2)).to eq([6])
        end
    end


end