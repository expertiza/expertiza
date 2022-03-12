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
      allow(MarkupStyle).to receive(:find).with('1').and_return(markup_style)
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
#      it 'redirects to list' do
#        get :list
#        expect(response).to redirect_to('/roles')
#      end
    end

    describe '#show' do
        context 'when try to show a markupstyle' do
          
            it 'renders markup_style#show when find the target markupstyle' do
              @params = {
                id: 1
              }
              get :show, @params
              expect(response).to render_template(:show)
            end
          end
      
    end

    describe '#new' do
      it 'creates a new markup style object and renders MarkupStyle#new page' do
        get :new
        expect(response).to render_template(:new)
      end  
    end

    describe '#create' do
      context 'when markup style is saved successfully' do
        it 'redirects to markup_style#list page' do
          allow(MarkupStyle).to receive(:name).and_return('test markup_style')
          @params = {
            markup_style: {
              name: 'test markup_style'
            }
          }
          post :create, @params
          expect(response).to redirect_to('/markup_styles/list')
        end
      end
      context 'when markup_style is not saved successfully' do
        it 'renders markup_style#new page' do
          allow(markup_style).to receive(:save).and_return(false)
          @params = {
            markup_style: {
              name: 'test'
            }
          }
          post :create, @params
          expect(flash.now[:error]).to eq('The creation of the markup_style failed.')
          expect(response).to render_template(:new)
        end
      end      
    end

    describe '#edit' do
      it 'renders markup_style#edit' do
        @params = {
          id: 1
        }
        get :edit, @params
        expect(response).to render_template(:edit)
      end
    end

    describe '#update' do
      context 'when markupstyle is updated successfully' do
        it 'renders markupstyle#list' do
          @params = {
            id: 1,
            markup_style: {
              name: 'test markup style'
            }
          }
          put :update, @params
          expect(response).to redirect_to('/markup_styles/1')
        end
      end
      context 'when markup_style is not updated successfully' do
        it 'renders markup_style#edit' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          @params = {
            id: 1,
            markup_style: {
              name: 'test markup style'
            }
          }
          allow(MarkupStyle).to receive(:update_attribute).with(any_args).and_return(false)
          put :update, @params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe '#destroy' do
      context 'when try to delete a markup style' do
        it 'renders markup_style#list when delete successfully' do
          @params = {
            id: 1
          }
          post :destroy, @params, session
          expect(response).to redirect_to('/markup_styles/list')
        end
      end
    end

end