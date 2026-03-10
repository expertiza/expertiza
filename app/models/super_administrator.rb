class SuperAdministrator < User
  def self.get_user_list
    # This function returns a list of all users in the system.
    user_list = []
    User.all.find_each do |user|
      user_list << user
    end
    user_list
  end
end
