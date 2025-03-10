class UserMapping
  def self.run!
    file = File.open('user_mapping.csv', 'w')
    File.write('user_mapping.csv', "UserID, ScrubbedUserID,\n", mode: 'a')
    User.find_each do |user|
      user_id = user.id
      scrubbed_name = "#{user.role.name.downcase.gsub(/[- ]/, '_')}#{user.id}"
      File.write('user_mapping.csv', user_id.to_s + ', ' + scrubbed_name + ",\n", mode: 'a')
    end
    file.close
  end
end
