class ScrubDatabase
  def self.run!
    User.find_each do |user|
      user.name = "#{user.role.name.downcase.gsub(/[- ]/, '_')}#{user.id}"
      user.fullname = "#{user.id}, #{user.role.name.downcase.gsub(/[- ]/, '_')}"
      user.email = 'expertiza@mailinator.com'
      user.handle = 'handle'
      user.password = 'password'
      # user.password_confirmation = "password"
      user.save(validate: false)
    end
    Participant.find_each do |participant|
      participant.handle = 'handle'
      participant.save(validate: false)
    end
  end
end
