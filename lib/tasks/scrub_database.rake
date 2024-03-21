require 'faker'
# require 'i18n'

namespace :db do
  namespace :data do
    desc 'Scrubs the database of user information'
    task scrub: :environment do
      # Require the data migration class
      require './db/data_migrations/scrub_database.rb'
      # require './db/schema.rb'
      ScrubDatabase.run!
      # ScrubDatabase.delduplis!
    end
  end
end
