require "#{File.dirname(__FILE__)}/../craken"

namespace :craken do

  desc "Install raketab script"
  task :install do
    require 'erb'
    include Craken
    unless RAKETAB_FILES.empty?
      files = (plural = RAKETAB_FILES.size > 1) ? RAKETAB_FILES.join(", ") : RAKETAB_FILES.first
      puts "craken:install => Using raketab file#{plural ? 's' : ''} #{files}" 
      crontab = append_tasks(load_and_strip, raketab)
      install crontab
    end
  end

  desc "Uninstall cron jobs associated with application"
  task :uninstall do
    include Craken
    # install stripped cron
    install load_and_strip
  end

end
