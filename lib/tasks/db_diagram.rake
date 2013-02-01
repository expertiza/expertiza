namespace :db do
    desc 'Outputs the current database schema diagram to ./db'
    task :diagram do
        # Check SQLFairy dependency
        sqlt_path = %x[which sqlt-graph]
        if sqlt_path.nil? or sqlt_path.empty?
          puts 'This task requires sqlt-graph from SQLFairy.'
          exit 1
        end

        begin
            puts 'Creating the database schema diagram...'
            db_config = YAML.load(File.new('config/database.yml').read)
            db_user = db_config['development']['username']
            db_pass = db_config['development']['password']
            password_args = (db_pass.nil? ? '' : "--password=#{db_pass}")

            %x[mysqldump -u root -d pg_development #{password_args} > ./db/tmp_schema.sql]
            %x[sqlt-graph -f MySQL -o ./db/pg_development.png -t png db/tmp_schema.sql]
        rescue Exception => e
            puts 'ERROR: There was a problem generating the diagram. ' + e.message
        else
            puts 'The file db/pg_development.png has been successfully created!'
        ensure
            %x[rm -f db/tmp_schema.sql]
        end
    end
end
