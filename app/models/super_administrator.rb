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


class SuperAdministrator < User
  
  QUESTIONNAIRE = [["My instructor's questionnaires",'list_instructors'],
            ["My admin's questionnaires",'list_admins'],
            ["My questionnaires",'list_mine'],
            ['All public questionnaires','list_all'],
            ['All private questionnaires','list_all_private']]
            
  SIGNUPSHEET = [["My instructor's signups",'list_instructors'],
            ["My admin's signups",'list_admins'],
            ['My signups','list_mine'],
            ['All public signups','list_all'],
            ['All private signups','list_all_private']]          
 
  ASSIGNMENT = [["My instructor's assignments",'list_instructors'],
                ["My admin's assignments",'list_admins'],
                ['My assignments','list_mine'],
                ['All public assignments','list_all'],
                ['All private assignments','list_all_private']]

  def get(object_type, id, user_id)
      object_type.find(:first, :conditions => ["id = ?", id])
  end

  def list_all(object_type, user_id)
    object_type.find(:all, :conditions => "private = 0")
  end
   
  def list_all_private(object_type, user_id)
    object_type.find(:all, :conditions => "private = 1")
  end
   
  def list_admins(object_type, user_id)
    if (object_type != SignupSheet)
      object_type.find(:all,
                       :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    else 
      object_type.find(:all,
                       :joins => "inner join users on instructor_id = users.id AND users.parent_id = " + user_id.to_s)  
    end                 
  end

  def list_instructors(object_type, user_id)
    if (object_type != SignupSheet)
      object_type.find(:all,
                       :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    else
      object_type.find(:all,
                       :joins => "inner join users on instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    end                   
  end

  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ?", id])
  end
end
