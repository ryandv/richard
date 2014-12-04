#https://support.cloud.engineyard.com/entries/21016568-Use-Ruby-Deploy-Hooks

# Remember that, in order for migrations to run, your entire environment is loaded.
# So if you have any symlinks that need to be created in order for the application to start properly,
# put them in before_migrate.rb instead of before_symlink.rb, because before_symlink.rb runs after the migration.

Chef::Log.info("mkdir shared_path/config")
run "mkdir -p #{config.shared_path}/config"

Chef::Log.info("symlinking config files")
run "sudo! ln -fs #{config.shared_path}/config/database.yml #{config.release_path}/config/database.yml"

run "sudo! ln -fs #{config.shared_path}/config/google-apps.yml #{config.release_path}/config/google-apps.yml"

run "sudo! ln -fs #{config.shared_path}/config/nginx.conf #{config.release_path}/config/nginx.conf"

Chef::Log.info("create logging")
run "mkdir -p #{config.shared_path}/log"
run "touch #{config.shared_path}/log/production.log"






# desc "Restart Passenger gracefully"
# task :apprestart, :roles => :app, :except => { :no_release => true } do
run "sudo! touch #{File.join(config.current_path,'tmp','restart.txt')}"

# desc "Reload Nginx config changes"
# task :webrestart, :roles => :web, :except => { :no_release => true } do
run "sudo! service nginx reload"

# namespace :assets do
# task :precompile, :roles => :web, :except => { :no_release => true } do
run %Q{cd #{config.release_path} && #{rake} RAILS_ENV=#{config.framework_env} #{asset_env} assets:precompile}

# task :cleanup, :except => {:no_release => true} do
count = fetch(:keep_releases, 5).to_i
sudo! "ls -1dt #{releases_path}/* | tail -n +#{count + 1} | xargs rm -rf"

# desc "Update the crontab file"
run "cd #{config.release_path} && bundle exec whenever --update-crontab #{app}"