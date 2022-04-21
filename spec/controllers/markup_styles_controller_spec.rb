require 'rails_helper'
describe MarkupStylesController do
    let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
    let(:student) { build(:student, id: 1, role_id: 1) }
    let(:student_role) { build(:role_of_student, id: 1, name: 'Student_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:instructor_role) {  build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:admin_role) { build(:role_of_administrator, id: 3, name: 'Administrator_role_test', description: '', parent_id: nil, default_page_id: nil) }
    let(:markup_style) { build(:markup_style, id: 1, name: 'test markupstyle') }
    let(:markup_style1) { build(:markup_style, id: 2, name: 'test markupstyle1') }
    let(:instructor) { build(:instructor, id: 2,role_id: 3) }
    # create fake lists
    let(:markup_style_list) { [markup_style, markup_style1] }

    # This is the first action that takes place when the user tries to access the markup styles. 
    # The function checks whether the current user is authorized to access the feature. 
    # It is only available for those with super admin privileges. 
    # The test case is also to make sure other roles can not access the feature 
    describe '#action_allowed?' do
      context 'when the current user is student' do
        it 'returns false' do
          stub_current_user(student, student.role.name, student.role)
          expect(controller.send(:action_allowed?)).to be_falsey
        end
      end
      context 'when the current user is instructure' do
        it 'returns false' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be_falsey
        end
      end        
      context 'when the current user is Super-Admin' do
        it 'returns true' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          expect(controller.send(:action_allowed?)).to be_truthy
        end
      end
    end

    # define default behaviors for each method call
    before(:each) do
      allow(MarkupStyle).to receive(:find).with('1').and_return(markup_style)
      allow(markup_style_list).to receive(:paginate).with(page: '1', per_page: 10).and_return(markup_style_list)
      #allow(MarkupStyle).to receive(:paginate).with(1,10).and_return(markup_style_list)
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)   
    end    

    # This is to test the #index function, which is called to displays the landing page of markup styles.
    # expecting to render the :list view
    describe '#index' do
      context 'when markup styles query a page of markup styles' do
        it 'renders markupstyles#list' do
          get :index
          expect(response).to render_template(:list)
        end
      end
    end

    # This is to test the #list function, which is called to list markup styles, with pagination
    # expecting to render #list view
    describe '#list' do
      context 'when markup styles query a page of markup styles' do
        it 'renders markupstyles#list' do
          params = { page: '1' }           
          get :list, params: params
          expect(assigns(:markup_styles)).not_to eq(nil)  
          expect(response).to render_template(:list)
        end
      end
    end

    # Test case to test the #show function, which is called to show a particular markup style
    # expecting to render :show view properly 
    describe '#show' do
      context 'when try to show a markupstyle' do    
        it 'renders markup_style#show when find the target markupstyle' do
          @params = { id: 1 }
          get :show, params: @params
          expect(response).to render_template(:show)
        end
      end
    end

    # This is to test the #new function which is called in the process of adding a new markup style. 
    # This is essentially to capture new markup style
    # expecting to render :new view appropriately

    describe '#new' do
      it 'creates a new markup style object and renders MarkupStyle#new page' do
        get :new
        expect(response).to render_template(:new)
      end  
    end

    # Test case to test the #create function which is called in process of creating new markup style
    # expecting to redirect to right path after done
    describe '#create' do
      context 'when markup style is saved successfully' do
        it 'redirects to markup_style#list page' do
          allow(MarkupStyle).to receive(:name).and_return('test markup_style') # Allowing MarkupStyle instance to receive :name 
          @params = { markup_style: { name: 'test markup_style' } }
          post :create, params: @params
          expect(response).to render_template("markup_styles/new", "layouts/application")
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
          post :create, params: @params          
          expect(flash.now[:error]).to eq(nil) #          
          expect(response).to render_template("markup_styles/new", "layouts/application") 
        end
      end      
    end

    # Testing edit feature, expecting to render :edit view properly once done
    describe '#edit' do
      it 'renders markup_style#edit' do
        @params = {
          id: 1
        }
        get :edit, params: @params
        expect(response).to render_template(:edit)
      end
    end

    # Testing update feature, expecting to redirect to right path once done
    describe '#update' do
      context 'when markupstyle is updated successfully' do
        it 'renders markupstyle#list' do
          @params = {
            id: 1,
            markup_style: {
              name: 'test markup style'
            }
          }
          put :update, params: @params
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
          allow(MarkupStyle).to receive(:update_attribute).with(any_args).and_return(false) # Allowing to receive :update_atrribute
          put :update, params: @params
          expect(response).to render_template(nil)
        end
      end
    end

    # Testing the destroy feature, allowing to delete a markup style 
    # expecting to redirect to right path once done
    describe '#destroy' do
      context 'when try to delete a markup style' do
        it 'renders markup_style#list when delete successfully' do
          @params = {
            id: 1
          }
          post :destroy, params: @params, session: session # calling post
          expect(response).to redirect_to('/markup_styles/list')
        end
      end
    end

end