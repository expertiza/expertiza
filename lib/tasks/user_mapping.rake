namespace :db do
  namespace :data do
    desc 'Maps user ids to anonymous user ids'
    task map: :environment do
      # Require the data migration class
      require './db/data_migrations/user_mapping.rb'

      UserMapping.run!
    end
  end
end
