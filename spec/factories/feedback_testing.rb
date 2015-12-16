FactoryGirl.define do

  factory :user do
    name 'student1300'
    role_id 1
    password 'student1300'
    password_confirmation 'student1300'
    email 'a@a.com'
  end

  factory :feedback_setting do
    support_mail 'sgandhi4@ncsu.edu'
    max_attachments '1'
    max_attachment_size '2048'
    wrong_retries '5'
    wait_duration '5'
    wait_duration_increment '5'
    support_team 'a@a.com,b@b.com'
  end

  factory :feedback_attachment_setting do
    file_type 'application/x-ruby'
  end

end