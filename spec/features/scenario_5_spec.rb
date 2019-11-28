require( 'spec_helper')
describe 'password reset request',js: true do
  before(:each) do
    #create(:student)
    #visit '/'
    #click_link 'Forgot password?'
    #Selenium::WebDriver.logger.level = :debug
  end

  context 'invalid email' do
    it 'invalid email', js: true do
      visit '/'
      click_link 'Forgot password?'
      expect(page).to have_current_path('/password_retrieval/forgotten')
      fill_in 'user_email', with: 'dummy'
      click_button 'Request password'
      expect(page).to have_content('No account is associated with the e-mail address ‘dummy’:  Please try again')
    end
    end

  it 'email does not exist'
  context 'no input' do
    it 'no input', js: true do
      visit '/'
      click_link 'Forgot password?'
      expect(page).to have_current_path('/password_retrieval/forgotten')
      click_button 'Request password'
      expect(page).to have_content('No account is associated with the e-mail address ‘dummy’:  Please try again')
    end
  end
  it 'works correctly' do
    visit '/'
    click_link 'Forgot password?'
    expect(page).to have_current_path('/password_retrieval/forgotten')
    fill_in 'user_email', with: 'expertiza@mailinator.com'
    click_button 'Request password'
    expect(page).to have_content('A link to reset your password has been sent to your e-mail address.')
  end

end