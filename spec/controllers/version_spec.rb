require 'rails_helper'
include LogInHelper

describe VersionsController do

  context 'user not logged in' do
    it 'should not be able to add a new version' do
      get :new
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not be able to create a version' do
      get :create, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not be able to update a version' do
      get :update, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not be able to edit a version' do
      get :edit, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not be able to see versions' do
      get :index
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow to call destroy_all versions' do
      delete :destroy_all
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow to call destroy versions' do
      delete :destroy, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end
  end


  context 'logged in as student' do
    before(:each) do
      #setup fake login
      student.save
      @user = User.find_by_name('student')
      @role = double('role', :super_admin? => false)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
    end

    it 'should not allow student to call destroy_all versions' do
      delete :destroy_all
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow student to be able to add a new version' do
      get :new
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end


    it 'should not allow student to be able to create a version' do
      get :create, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow student to be able to update a version' do
      get :update, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow student to be able to edit a version' do
      get :edit, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should allow student to be able to see versions' do
      get :index
      expect(response).should redirect_to versions_search_path
    end
  end

  context 'logged in as administrator' do
    before(:each) do
      #setup fake login
      @user = double('admin', :timezonepref => 'Eastern Time (US & Canada)')
      @role = double('role', :super_admin? => false)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Administrator')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
    end

    it 'should allow admin to call destroy_all versions' do
      delete :destroy_all
      expect(response).should redirect_to versions_path
    end

    #TODO: stud Version.find
    # it 'should allow admin to call destroy version' do
    #   delete :destroy, { id: 1 }
    #   expect(response).should redirect_to versions_path
    # end

    it 'should not allow admin to be able to add new version' do
      get :new
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow admin to be able to create a version' do
      get :create, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow admin to be able to update a version' do
      get :update, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow admin to be able to edit a version' do
      get :edit, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should allow admin to be able to see versions' do
      get :index
      expect(response).should redirect_to versions_search_path
    end
  end

  context 'logged in as instructor' do
    before(:each) do
      #setup fake login
      @user = double('instructor', :timezonepref => 'Eastern Time (US & Canada)')
      @role = double('role', :super_admin? => false)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Instructor')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
    end

    it 'should not allow instructor to call destroy_all versions' do
      delete :destroy_all
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow instructor to be able to add new version' do
      get :new
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow instructor to be able to update a version' do
      get :update, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow instructor to be able to edit a version' do
      get :edit, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow instructor to be able to create a version' do
      get :create, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should allow instructor to be able to see versions' do
      get :index
      expect(response).should redirect_to versions_search_path
    end
  end
  context 'logged in as Teaching Assistant' do
    before(:each) do
      #setup fake login
      @user = double('Teaching Assistant', :timezonepref => 'Eastern Time (US & Canada)')
      @role = double('role', :super_admin? => false)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Teaching Assistant')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
    end

    it 'should not allow Teaching Assistant to call destroy_all versions' do
      delete :destroy_all
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow Teaching Assistant to be able to add new version' do
      get :new
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow Teaching Assistant to be able to update a version' do
      get :update, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow Teaching Assistant to be able to edit a version' do
      get :edit, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should not allow Teaching Assistant to be able to create a version' do
      get :create, { id: 1 }
      expect(response).should redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
    end

    it 'should allow Teaching Assistant to be able to see versions' do
      get :index
      expect(response).should redirect_to versions_search_path
    end
  end

end

