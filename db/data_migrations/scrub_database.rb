require 'yaml'

class ScrubDatabase
  def self.run!
    # Loop through each user
    User.find_each do |user|
      # Generate a new fake user record
      loop do
        fake_name = FakeNameGenerator.first_name
        fake_lastname = FakeNameGenerator.last_name
        num = rand(1..9)
        role = user.role.name.downcase.gsub(/[- ]/, '_')
        user.username = role == 'student' ? "#{fake_name}_#{fake_lastname[0..3]}#{num}" : "#{role}_#{fake_name}__#{fake_lastname[0..3]}"
        user.name = role == 'student' ? "#{fake_lastname}, #{fake_name}" : "#{fake_name}, #{role}"
        user.email = 'expertiza@mailinator.com'
        user.handle = 'handle'
        user.password = 'password'
        username = role == 'student' ? "#{fake_name}_#{fake_lastname[0..3]}#{num}" : "#{role}_#{fake_name}__#{fake_lastname[0..3]}"
        # Checking if username already exists
        if User.find_by(:name => username) == nil #no record exists of that username
          # print "new user"
          user.save(validate: false)
          break
        end
        # if record exists, generate new fake record by going through the loop again
      end
    end

    Participant.find_each do |participant|
      participant.handle = 'handle'
      participant.save(validate: false)
    end
  end
end


class FakeNameGenerator
  NAMES = YAML.load_file("#{Rails.root}/config/name.yml")['name']

  def self.first_name
    gender = [:male_first_name, :female_first_name, :neutral_first_name].sample
    NAMES["#{gender}"].sample
  end

  def self.last_name
    NAMES["#{:last_name}"].sample
  end
end