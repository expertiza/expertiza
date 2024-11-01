namespace :db do
  namespace :data do
    desc 'Maps user ids to anonymous user ids'
    task unity_map: :environment do
      # Require the data migration class
      require './db/data_migrations/unity_mapping.rb'

      UnityMapping.run!
    end
  end
end
