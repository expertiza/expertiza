require 'csv'

module ImportFileHelper
  def self.define_attributes(row)
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session)
    user = User.new(user_params(attributes))
    user.parent_id = (session[:user]).id
    user.timezonepref = User.find(user.parent_id).timezonepref
    user.save!
    user
  end

  private

  def user_params(params_hash)
    params_local = params
    params_local[:user] = params_hash
    params_local.require(:user).permit(:name,
                                       :crypted_password,
                                       :role_id,
                                       :password_salt,
                                       :fullname,
                                       :email,
                                       :parent_id,
                                       :private_by_default,
                                       :mru_directory_path,
                                       :email_on_review,
                                       :email_on_submission,
                                       :email_on_review_of_review,
                                       :is_new_user,
                                       :master_permission_granted,
                                       :handle,
                                       :digital_certificate,
                                       :persistence_token,
                                       :timezonepref,
                                       :public_key,
                                       :copy_of_emails,
                                       :institution_id)
  end
end
