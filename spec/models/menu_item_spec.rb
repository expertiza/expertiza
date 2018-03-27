describe MenuItem  do
  let!(:menuitem) {MenuItem.create id: 1, parent_id: nil, name: "navigate", label: "Navigate", seq: 1, controller_action_id: 1, content_page_id: 1}
  let!(:menuitem_home){MenuItem.create id: 2, parent_id: nil, name: "home", label: "Home", seq: 2, controller_action_id: 0, content_page_id: 1}
  let(:menuitem_contact_us){MenuItem.create id: 3, parent_id: nil, name: "contact_us", label:"Contact Us", seq: 3, controller_action_id: 1, content_page_id: 1}
  let(:menuitem_credits){MenuItem.create id: 4, parent_id: 3, name: "credits", label:"Credits", seq: 4, controller_action_id: 1, content_page_id: 1}
  let(:menuitem_licenses){MenuItem.create id: 5, parent_id: 3, name: "licenses", label:"Licenses", seq: 5, controller_action_id: 0, content_page_id: 1}
  let!(:controller_action){ControllerAction.create id: 1, site_controller_id: 1, name: "view_default", permission_id: 3, url_to_use: nil}
  let!(:content_page) {ContentPage.create id: 1, title: "Home Page", name: "home", markup_style_id: 0, content: "<h1>Welcome to Expertiza</h1>", permission_id: 3, content_cache: "<h1>Welcome to Expertiza</h1>" }

  it "is net valid without a name" do
    menuitem.name = nil
    menuitem.should_not be_valid
  end

  it "Find or Create by Name" do
    expect(MenuItem.find_or_create_by_name(menuitem.name)).to be_valid
  end

  it "Above a child item with parent is NULL" do
    allow(MenuItem).to receive(:where).with(['parent_id is null and seq = ?', 1] ).and_return([menuitem])
    expect(menuitem_home.above).to eq(menuitem)
  end

  it "Above a child item with parent is not NULL" do
    allow(MenuItem).to receive(:where).with(['parent_id = ? and seq = ?', 3,4] ).and_return([menuitem_credits])
    expect(menuitem_licenses.above).to eq(menuitem_credits)
  end

  it "Below a parent item with parent is  NULL" do
    allow(MenuItem).to receive(:where).with(['parent_id is null and seq = ?', 2] ).and_return([menuitem_home])
    expect(menuitem.below).to eq(menuitem_home)
  end

  it "Below a parent item with parent is not NULL" do
    allow(MenuItem).to receive(:where).with(['parent_id = ? and seq = ?', 3,5] ).and_return([menuitem_licenses])
    expect(menuitem_credits.below).to eq(menuitem_licenses)
  end

  it "Delete a Parent Menu Item" do
    allow(MenuItem).to receive(:where).with('parent_id = ?', 3).and_return([menuitem_credits, menuitem_licenses])
    allow(MenuItem).to receive(:where).with('parent_id = ?', 4).and_return([])
    allow(MenuItem).to receive(:where).with('parent_id = ?', 5).and_return([])
    menuitem_contact_us.delete 
    MenuItem.all.each{|x| puts x.name}
    expect(MenuItem.count).to eq(2)
  end

  it "Next Seq where parent is NULL" do
    allow(MenuItem).to receive(:where).with(['parent_id is null']).and_return([menuitem, menuitem_home, menuitem_contact_us])
    expect(MenuItem.next_seq(menuitem.parent_id)).to eq(4)
  end

  it "Next Seq where parent is not NULL" do
    allow(MenuItem).to receive(:where).with([parent_id: 3]).and_return([menuitem_contact_us, menuitem_licenses])
    expect(MenuItem.next_seq(3)).to eq(6)
  end

  it "Items for permission with permission_id nil" do
    
    expect(MenuItem.items_for_permissions()).to match_array([menuitem, menuitem_home])
  end 
  it "Items for permission with permission_id from Controller Action" do
    expect(MenuItem.items_for_permissions([controller_action.permission_id])).to match_array([menuitem, menuitem_home])
  end 

  it "repack Contact Us in Navigate" do
    allow(MenuItem).to receive_message_chain(:where,:order).with('parent_id = ?', 3).with('seq').and_return([menuitem_credits, menuitem_licenses])
    menuitem_contact_us.parent_id = 1
    expect{MenuItem.repack(menuitem_contact_us.id)}.to change{menuitem_credits.seq}.from(4).to(1)
  end

  it "repack Credits in Root" do
    allow(MenuItem).to receive_message_chain(:where,:order).with('parent_id is null').with('seq').and_return([menuitem,menuitem_home,menuitem_contact_us,menuitem_credits])
    menuitem_credits.parent_id = nil
    expect{MenuItem.repack(nil)}.to_not change{menuitem_credits.seq}
  end

end
