namespace :db do
  desc 'Outputs the current database schema diagram to ./db'
  task :diagram do
    # Check SQLFairy dependency
    sqlt_path = `which sqlt-graph`
    exit 1 if sqlt_path.nil? || sqlt_path.empty?

    begin
      db_config = YAML.safe_load(File.new('config/database.yml').read)
      db_pass = db_config['development']['password']
      password_args = (db_pass.nil? ? '' : "--password=#{db_pass}")

      `mysqldump -u root -d pg_development #{password_args} > ./db/tmp_schema.sql`
      `sqlt-graph -f MySQL -o ./db/pg_development.png -t png db/tmp_schema.sql`
    rescue
      nil
    else
    ensure
      `rm -f db/tmp_schema.sql`
    end
  end
end
