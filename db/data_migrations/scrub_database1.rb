# frozen_string_literal: true

# Include in Gemfile
# gem 'faker', '~> 1.6', '>= 1.6.6'
#  OR
# Install
# gem install faker -v 1.6.6

class ScrubDatabase
  def self.run!
    User.find_each do |user|
      fake_name = Faker::Name.first_name
      user.name = "#{user.role.name.downcase.gsub(/[- ]/, '_')}#{fake_name}"
      user.fullname = "#{fake_name}, #{user.role.name.downcase.gsub(/[- ]/, '_')}"
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
