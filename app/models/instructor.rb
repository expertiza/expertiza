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


class Instructor < User
  
  QUESTIONNAIRE = [['My questionnaires','list_mine'],
            ['All public questionnaires','list_all']]
            
   SIGNUPSHEET = [['My signups','list_mine'],
            ['All public signups','list_all']]       
  
  ASSIGNMENT = [['My assignments','list_mine'],
                ['All public assignments','list_all']]

  def list_all(object_type, user_id)
    object_type.find(:all, 
                     :conditions => ["instructor_id = ? OR private = 0", user_id])
  end
  
  def list_mine(object_type, user_id)
    object_type.find(:all, :conditions => ["instructor_id = ?", user_id])
  end
  
  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ? AND (instructor_id = ? OR private = 0)", 
                                     id, user_id])
  end
end
