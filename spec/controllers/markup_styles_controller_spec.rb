require 'rails_helper'
describe MarkupStylesController do
    let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
    let(:student) { build(:student, id: 1, role_id: 1) }
    let(:student_role) { build(:role_of_student, id: 1, name: 'Student_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:instructor_role) {  build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:admin_role) { build(:role_of_administrator, id: 3, name: 'Administrator_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:markup_style) { build(:markup_style, id: 1, name: 'test markupstyles') }
        

    describe '#action_allowed?' do
        context 'when the current user is student' do
            it 'returns false' do
              stub_current_user(student, student.role.name, student.role)
              expect(controller.send(:action_allowed?)).to be_falsey
            end
          end
          context 'when the current user is Super-Admin' do
            it 'returns false' do
              stub_current_user(super_admin, super_admin.role.name, super_admin.role)
              expect(controller.send(:action_allowed?)).to be_truthy
            end
          end
    end

    # define default behaviors for each method call
    before(:each) do
      allow(MarkupStyle).to receive(:find).with('1').and_return(markupstyles)
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        
    end    

    describe '#index' do
        context 'when markup styles query a page of markup styles' do
            it 'renders markupstyles#list' do
              get :index
              expect(response).to render_template(:list)
            end
        end
    end

    describe '#list' do
        #Include tests here
    end

    describe '#show' do
        context 'when try to show a markupstyle' do
          
            it 'renders markupstyles#show when find the target markupstyle' do
              @params = {
                id: 1
              }
              get :show, @params
              expect(response).to render_template(:show)
            end
          end
      
    end

    describe '#new' do
        #Include tests here
    end

    describe '#create' do
        #Include tests here
    end

    describe '#edit' do
        #Include tests here
    end

    describe '#update' do
        #Include tests here
    end

    describe '#destroy' do
        #Include tests here
    end

end