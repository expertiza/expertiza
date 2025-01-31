class UnityMapping
  def self.run!
    file = File.open('unity_mapping.csv', 'w')
    File.write('unity_mapping.csv', "UserID, Unity ID,\n", mode: 'a')
    User.find_each do |user|
      user_id = user.id
      unity_id = user.email.split('@').first
      File.write('unity_mapping.csv', user_id.to_s + ', ' + unity_id + ",\n", mode: 'a')
    end
    file.close
  end
end
