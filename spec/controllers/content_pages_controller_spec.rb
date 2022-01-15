describe ContentPagesController do
    let(:instructor) { build(:instructor, id: 6) }
    let(:content_page_home) {build(:content_page, id: 1)}
    
    before(:each) do
        stub_current_user(instructor, instructor.role.name, instructor.role)
    end

    describe '#view' do
        context "when ContentPage found" do
            it "retrieves ContentPage by page_name and render content_pages#view page" do
                allow(ContentPage).to receive(:find_by).with(name: 'home').and_return(content_page_home)
                params = {page_name: "home"}
                get :view, params
                expect(controller.instance_variable_get(:@content_page).title).to eq("Expertiza Home")
                expect(response).to render_template(:view)
            end

            it "retrieves ContentPage by settings not_found_page_id and render content_pages#view page" do
                controller.instance_variable_set(:@settings, SystemSettings.new(not_found_page_id: 1))
                allow(ContentPage).to receive(:find).with(1).and_return(content_page_home)
                params = {page_name: "unknown"}
                get :view, params
                expect(controller.instance_variable_get(:@content_page).title).to eq("Expertiza Home")
                expect(response).to render_template(:view)
            end
        end

        context "when no content page found" do
            it "creates new ContentPage object with id=nil and render ontent_pages#view page" do
                params = {page_name: "not found"}
                get :view, params
                expect(controller.instance_variable_get(:@content_page).content).to eq('(no such page)')
                expect(response).to render_template(:view)
            end
        end
    end

end