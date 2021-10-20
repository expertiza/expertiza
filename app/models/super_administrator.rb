class SuperAdministrator < User
  def self.get_user_list
    user_list = []
    User.all.find_each do |user|
      user_list << user
    end
    user_list
  end
end
