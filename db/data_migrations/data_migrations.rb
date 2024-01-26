class DataMigrations
  def self.run!
    files = Dir['./db/data_migrations/*.rb'].reject do |s|
      s[/data_migrations.rb|scrub_database.rb/]
    end

    files.each do |file|
      require file
    end

    files.each do |file|
      file[/\w+.rb/][/\w+/].camelize.constantize.run!
    end
  end
end
