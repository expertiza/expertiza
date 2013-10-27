
namespace :goldberg do

  desc "Dump standard Goldberg tables to files in db/"
  task :dump_starter => :environment do
    goldberg_classes.each do |klass|
      dump_for_class klass, "db"
    end
  end

  desc "Load standard Goldberg tables from files in db/"
  task :load_starter => 'db:migrate' do
    goldberg_classes.each do |klass|
      load_for_class klass, "db"
    end
  end

  desc "Install Goldberg"
  task :install => :load_starter do
    index = "#{RAILS_ROOT}/public/index.html"
    FileTest.exists?(index) and File.delete(index)
  end

  desc "Flush cached data out of sessions and Roles"
  task :flush => :environment do
    puts "Deleting any Rails session files"
    Dir["#{RAILS_ROOT}/tmp/sessions/ruby_sess*"].each do |fname|
      File.delete fname
    end
    
    puts "Deleting any ActiveRecord sessions, and resetting the Role cache"
    conn = ActiveRecord::Base.connection
    
    begin  # Capture error if sessions table doesn't exist
      conn.execute "delete from sessions"
    end
    conn.execute "update roles set cache = NULL"
  end

  desc "Upgrade a legacy Goldberg database to the latest version"
  task :upgrade => [:flush, 'db:migrate'] do
  end

end


def goldberg_classes
  return [ MarkupStyle, Permission, SiteController, 
	   ContentPage, ControllerAction, MenuItem, 
           Role, RolesPermission, SystemSettings, User ]
end

def dump_for_class(klass, dest)
  filename = "#{dest}/#{klass.to_s}.yml"
  records = klass.find(:all)
  File.open(filename, 'w') do |out|  
    YAML.dump(records, out)
  end
end

def load_for_class(klass, src)
  filename = "#{src}/#{klass.to_s}.yml"
  File.open(filename) do |src|
    records = YAML::load(src)
    records.each do |src_rec|
      record = klass.new src_rec.attributes
      record.id = src_rec.id
      record.save or 
        puts "#{klass.to_s} record #{record} not saved!"
    end
  end
  # Reset table sequence if applicable (i.e. PostgreSQL)
  if klass.connection.respond_to?(:reset_pk_sequence!)
    klass.connection.reset_pk_sequence!(klass.table_name)
  end
end

