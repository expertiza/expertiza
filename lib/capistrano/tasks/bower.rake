namespace :bower do
  desc 'Install bower dependencies'
  task :install do
    on roles(:web) do
      within shared_path do
        execute :bower, 'install', '--allow-root',
                "--config.directory=#{shared_path}/vendor/assets/components"
      end
    end
  end
end

before 'deploy:assets:precompile', 'bower:install'
