require 'spec_helper'

describe AdminController do
  describe 'list_administrators' do
    it 'routes' do
      visit '/'
      fill_in 'User Name', 'admin'
      fill_in 'Password', 'admin'
      click_button 'Login'

      visit '/admin/list_administrators'
    end
  end
end
