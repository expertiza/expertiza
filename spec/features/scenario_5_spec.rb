require 'rails_helper'

  RSpec.feature 'Password Reset', type: :feature do
    context 'Reset Password' do
      scenario 'Email not associated with any account' do

        visit '/'
        click_link 'Forgot password?'
        expect(page).to have_current_path('/password_retrieval/forgotten')
        fill_in 'user_email', with: 'expertiza@mailinator.com'
        click_button 'Request password'
      end
    end
  end
