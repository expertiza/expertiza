namespace :db do
  namespace :data do
    desc 'Performs all idempotent data migrations'
    task migrate: :environment do
      # Require the data migration class
      require './db/data_migrations/data_migrations'

      DataMigrations.run!
    end
  end
end
