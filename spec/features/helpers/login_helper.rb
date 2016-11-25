module LogInHelper
  def log_in(name, password)

    visit '/'
    fill_in 'User Name', with: name
    fill_in 'Password', with: password
    click_button 'SIGN IN'

  end
end