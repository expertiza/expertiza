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
  end
end
