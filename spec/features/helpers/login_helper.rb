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

  def user1
    User.where(name: 'user1').first || User.new({
      "name"=>"user1",
      "crypted_password"=>"bd08fb03e2e3115964b1b39ea40625292a776a86",
      "role_id"=>1,
      "password_salt"=>"tQ6OGFiyL9dIlwxeSJf",
      "fullname"=>"user1, Perfect",
      "email"=>"user1@dev.null",
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

  def user2
    User.where(name: 'user2').first || User.new({
      "name"=>"user2",
      "crypted_password"=>"bd08fb03e2e3115964b1b39ea40625292a776a86",
      "role_id"=>1,
      "password_salt"=>"tQ6OGFiyL9dIlwxeSJf",
      "fullname"=>"user2, Perfect",
      "email"=>"user2@dev.null",
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

  def user3
    User.where(name: 'user3').first || User.new({
      "name"=>"user3",
      "crypted_password"=>"bd08fb03e2e3115964b1b39ea40625292a776a86",
      "role_id"=>1,
      "password_salt"=>"tQ6OGFiyL9dIlwxeSJf",
      "fullname"=>"user3, Perfect",
      "email"=>"user3@dev.null",
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

  def user4
    User.where(name: 'user4').first || User.new({
      "name"=>"user4",
      "crypted_password"=>"bd08fb03e2e3115964b1b39ea40625292a776a86",
      "role_id"=>1,
      "password_salt"=>"tQ6OGFiyL9dIlwxeSJf",
      "fullname"=>"user4, Perfect",
      "email"=>"user4@dev.null",
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

=begin
  def user1
     User.new({
      name: "user1",
      password: "user1",
      password_confirmation: "user1",
      role_id: 1,
      fullname: "user1",
      email: "user1@ncsu.edu",
      parent_id: 1,
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

  def user2
     User.new({
      name: "user2",
      password: "user2",
      password_confirmation: "user2",
      role_id: 1,
      fullname: "user2",
      email: "user2@ncsu.edu",
      parent_id: 1,
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

    def user3
     User.new({
      name: "user3",
      password: "user3",
      password_confirmation: "user3",
      role_id: 1,
      fullname: "user3",
      email: "user3@ncsu.edu",
      parent_id: 1,
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

  def user4
     User.new({
      name: "user4",
      password: "user4",
      password_confirmation: "user4",
      role_id: 1,
      fullname: "user4",
      email: "user4@ncsu.edu",
      parent_id: 1,
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
=end

end
