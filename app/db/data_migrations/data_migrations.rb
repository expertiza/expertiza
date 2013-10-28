class DataMigrations
  def self.run!
    files = Dir['./db/data_migrations/*.rb'].reject do |s|
      s[/data_migrations.rb/]
    end

    files.each do |file|
      require file
    end

    files.each do |file|
      puts "Running #{file}"
      file[/\w+.rb/][/\w+/].camelize.constantize.run!
    end
  end
end
