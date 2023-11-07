require 'i18n'
# I18n.load_path += Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'faker/locales', '*.yml')]
require 'faker'
# I18n.reload!
# Faker::Config.locale = 'en'

class ScrubDatabase
  I18n.config.available_locales = %i[en de]
  I18n.default_locale = :en # prime savior of the faker gem
  
  
  I18n.reload!

  

  def self.run!
    duplisArray = []
    User.find_each do |user|
      loop do
        fake_name = Faker::Name.first_name
        fake_lastname = Faker::Name.last_name
        num = rand(1..9)
        role = user.role.name.downcase.gsub(/[- ]/, '_')
        user.name = role == 'student' ? "#{fake_name}_#{fake_lastname[0..3]}#{num}" : "#{role}_#{fake_name}__#{fake_lastname[0..3]}"
        user.fullname = role == 'student' ? "#{fake_lastname}, #{fake_name}" : "#{fake_name}, #{role}"
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
      end
    end

    Participant.find_each do |participant|
      participant.handle = 'handle'
      participant.save(validate: false)
    end
  end

end
