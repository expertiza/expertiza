namespace :db do
    desc 'Outputs the current database schema diagram to ./db'
    task :diagram do
        begin
            puts 'Creating the database schema diagram...'
            %x[mysqldump -u root -d pg_development > ./db/tmp_schema.sql]
            %x[sqlt-graph -f MySQL -o ./db/pg_development.png -t png ./db/tmp_schema.sql]
        rescue Exception => e
            puts 'ERROR: There was a problem generating the diagram. ' + e.message
        else
            puts 'The file .db/pg_development.png has been successfully created!'
        ensure
            %x[rm -f ./db/tmp_schema.sql]
        end
    end
end
