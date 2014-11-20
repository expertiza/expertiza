module LogInHelper
  def log_in(name, password)
    visit '/'
    expect(page).to have_content 'Login'

    fill_in 'User Name', with: name
    fill_in 'Password', with: password
    click_button 'Login'

    expect(page).to have_content "User: #{name}"
  end

  def student
    User.where(name: 'student').first || User.new({
      "name"=>"student",
      "crypted_password"=>"bd08fb03e2e3115964b1b39ea40625292a776a86",
      "role_id"=>1,
      "password_salt"=>"tQ6OGFiyL9dIlwxeSJf",
      "fullname"=>"Student, Perfect",
      "email"=>"pstudent@dev.null",
      "parent_id"=>1,
      "private_by_default"=>false,
      "mru_directory_path"=>nil,
      "email_on_review"=>true,
      "email_on_submission"=>true,
      "email_on_review_of_review"=>true,
      "is_new_user"=>false,
      "master_permission_granted"=>0,
      "handle"=>"",
      "leaderboard_privacy"=>false,
      "digital_certificate"=>nil,
      "timezonepref"=>"Eastern Time (US & Canada)",
      "copy_of_emails"=>false,
    })
  end

  def instructor
    User.where(name: 'instructor').first || User.new({
      name: "instructor",
      password: "password",
      password_confirmation: "password",
      role_id: 2,
      fullname: "Dole, Bob",
      email: "bdole@dev.null",
      parent_id: 2,
      private_by_default: false,
      mru_directory_path: nil,
      email_on_review: true,
      email_on_submission: true,
      email_on_review_of_review: true,
      is_new_user: false,
      master_permission_granted: 0,
      handle: "",
      leaderboard_privacy: false,
      digital_certificate: nil,
      public_key: nil,
      copy_of_emails: false,
    })
  end
end
