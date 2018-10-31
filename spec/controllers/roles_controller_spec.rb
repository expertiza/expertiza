require 'rspec'
require 'spec_helper'
RSpec.describe RolesController, type: :controller do
  describe 'Create a role' do
    include Capybara::DSL
    it 'should not create a new role' do
      visit roles_path
      expect(page).not_to have_button "New Role"
    end
    it 'should not create a new role from list' do
      visit list_roles_path
      expect(page).not_to have_button "New Role"
    end
    it 'should not create a new role and redirect to index page when "new" method is called' do
      visit new_role_path
      get :new
      response.should redirect_to '/'
      expect(flash[:error]).not_to be_nil
    end
  end
end
