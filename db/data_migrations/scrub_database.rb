class ScrubDatabase
  def self.run!
    # Loop through each user
    User.find_each do |user|
      role = user.role.name.downcase.gsub(/[- ]/, '_')
      user.name = "#{role}#{user.id}"
      user.fullname = "#{role}#{user.id}"
      user.email = 'expertiza@mailinator.com'
      user.handle = 'handle'
      user.password = 'password'
      user.save(validate: false)
    end

    Participant.find_each do |participant|
      participant.handle = 'handle'
      participant.save(validate: false)
    end
  end
end
