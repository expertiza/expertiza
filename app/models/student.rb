# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  name                      :string(255)      default(""), not null
#  crypted_password          :string(40)       default(""), not null
#  role_id                   :integer          default(0), not null
#  password_salt             :string(255)
#  fullname                  :string(255)
#  email                     :string(255)
#  parent_id                 :integer
#  private_by_default        :boolean          default(FALSE)
#  mru_directory_path        :string(128)
#  email_on_review           :boolean
#  email_on_submission       :boolean
#  email_on_review_of_review :boolean
#  is_new_user               :boolean          default(TRUE), not null
#  master_permission_granted :integer          default(0)
#  handle                    :string(255)
#  leaderboard_privacy       :boolean          default(FALSE)
#  digital_certificate       :text
#  persistence_token         :string(255)
#  timezonepref              :string(255)
#  public_key                :text
#  copy_of_emails            :boolean          default(FALSE)
#


class Student < User
  def get_home_action
    "list"
  end
  
  def get_home_controller
    return "student_task"
  end
end
