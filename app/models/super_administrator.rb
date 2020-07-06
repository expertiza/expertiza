class SuperAdministrator < User
  def self.user_list
    my_user_list = []
    User.all.find_each do |user|
      my_user_list << user
    end
    my_user_list
  end
end
