namespace :db do
    desc 'Outputs the current database schema diagram to ./db'
    task :diagram do
        # Check SQLFairy dependency
        sqlt_path = %x[which sqlt-graph]
        if sqlt_path.nil? or sqlt_path.empty?
          exit 1
        end

        begin
            db_config = YAML.load(File.new('config/database.yml').read)
            db_user = db_config['development']['username']
            db_pass = db_config['development']['password']
            password_args = (db_pass.nil? ? '' : "--password=#{db_pass}")

            %x[mysqldump -u root -d pg_development #{password_args} > ./db/tmp_schema.sql]
            %x[sqlt-graph -f MySQL -o ./db/pg_development.png -t png db/tmp_schema.sql]
        rescue Exception => e
        else
        ensure
            %x[rm -f db/tmp_schema.sql]
        end
    end
end
