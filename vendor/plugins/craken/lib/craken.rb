require 'socket'
require "#{File.dirname(__FILE__)}/raketab"

module Craken
  def self.determine_raketab_files
    if File.directory?("#{DEPLOY_PATH}/config/craken/") # Use hostname specific raketab first.
      raketabs = Dir["#{DEPLOY_PATH}/config/craken/*raketab*"].partition {|f| f =~ %r[/raketab.*$] }
      raketabs.last.empty? ? raketabs.first : raketabs.last.grep(/#{HOSTNAME}_raketab/)
    else
      Dir["#{DEPLOY_PATH}/config/raketab*"]
    end
  end

  HOSTNAME          = Socket.gethostname.split('.').first.downcase.strip
  DEPLOY_PATH       = ENV['deploy_path'] || RAILS_ROOT
  RAKETAB_FILES     = ENV['raketab_files'].split(":") rescue determine_raketab_files
  CRONTAB_EXE       = ENV['crontab_exe'] || "/usr/bin/crontab"
  #RAKE_EXE          = ENV['rake_exe'] || ((rake = `which rake`.strip and rake.empty?) ? "/usr/bin/rake" : rake)
  RAKETAB_RAILS_ENV = ENV['raketab_rails_env'] || RAILS_ENV
  # assumes root of app is name of app, also takes into account 
  # capistrano deployments
  APP_NAME          = ENV['app_name'] || (DEPLOY_PATH =~ /\/([^\/]*)\/releases\/\d*$/ ? $1 : File.basename(DEPLOY_PATH))

  # see here: http://unixhelp.ed.ac.uk/CGI/man-cgi?crontab+5
  SPECIAL_STRINGS   = %w[@reboot @yearly @annually @monthly @weekly @daily @midnight @hourly]

  CRONTAB_MARKER_START = "### #{APP_NAME} #{RAKETAB_RAILS_ENV} raketab start"
  CRONTAB_MARKER_END = "### #{APP_NAME} #{RAKETAB_RAILS_ENV} raketab end"
  # strip out the existing raketab cron tasks for this project
  def load_and_strip
    crontab = ''
    old = false
    `#{CRONTAB_EXE} -l`.each_line do |line|
      line.strip!
      if old || line == CRONTAB_MARKER_START
        old = line != CRONTAB_MARKER_END
      else
        crontab << line
        crontab << "\n"
      end
    end
    crontab
  end

  def append_tasks(crontab, raketab)
    crontab << "#{CRONTAB_MARKER_START}\n"
    raketab.each_line do |line|
      line.strip!
      unless line =~ /^#/ || line.empty? # ignore comments and blank lines
        sp = line.split
        if SPECIAL_STRINGS.include?(sp.first)
          crontab << sp.shift
          tasks = sp
        else
          crontab << sp[0,5].join(' ')
          tasks = sp[5,sp.size]
        end
        crontab << " cd #{DEPLOY_PATH} && #{RAKE_EXE} --silent RAILS_ENV=#{RAKETAB_RAILS_ENV}"
        tasks.each do |task|
          crontab << " #{task}"
        end
        crontab << "\n"
      end
    end
    crontab << "#{CRONTAB_MARKER_END}\n"
    crontab
  end

  # install new crontab
  def install(crontab)
    filename = ".crontab#{rand(9999)}" 
    File.open(filename, 'w') { |f| f.write crontab }
    `#{CRONTAB_EXE} #{filename}`
    FileUtils.rm filename
  end
  
  def raketab(files=RAKETAB_FILES)    
    files.map do |file|
      next unless File.exist?(file)
      builder = file =~ /.(\w+)$/ ? "build_raketab_from_#{$1}" : "build_raketab"
      send(builder.to_sym, file)
    end.join("\n")
  end
  
  private
    def build_raketab_from_rb(file)
      eval(File.new(file).read).tabs
    end
  
    def build_raketab_from_yml(file)
      yml = YAML::load(ERB.new(File.read(file)).result(binding))
      yml.map do |name,tab|
        format = []
        format << (tab['min'] || tab['minute'] || '0')
        format << (tab['hour'] || '0')
        format << (tab['day'] || '*')
        format << (tab['month'] =~ /^\d+$/ ? tab['month'] : Date._parse(tab['month'].to_s)[:mon] || '*')
        format << ((day = tab['weekday'] || tab['wday'] and day =~ /^\d+$/ ? day : Date._parse(day.to_s)[:wday]) || '*')
        format << tab['command']
        format.join(' ')        
      end.join("\n")
    end
    alias_method :build_raketab_from_yaml, :build_raketab_from_yml
    
    def build_raketab(file)
      ERB.new(File.read(file)).result(binding)
    end

    def method_missing(method, *args)
      method.to_s =~ /^build_raketab/ ? build_raketab(*args) : super
    end
end
