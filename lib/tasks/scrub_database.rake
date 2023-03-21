namespace :db do
  namespace :data do
    desc 'Scrubs the database of user information'
    task scrub: :environment do
      # Require the data migration class
      require './db/data_migrations/scrub_database.rb'

      ScrubDatabase.run!
    end
  end
end
