require 'spec_helper'

describe AdminController do
  describe 'list_administrators' do
    it 'routes' do
      visit '/'
      fill_in 'User Name', with: 'admin'
      fill_in 'Password', with: 'admin'
      click_button 'Login'
    end
  end
end
