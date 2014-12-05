#https://support.cloud.engineyard.com/entries/21016568-Use-Ruby-Deploy-Hooks

# Remember that, in order for migrations to run, your entire environment is loaded.
# So if you have any symlinks that need to be created in order for the application to start properly,
# put them in before_migrate.rb instead of before_symlink.rb, because before_symlink.rb runs after the migration.

Chef::Log.info("mkdir shared_path/config")
run "mkdir -p #{config.shared_path}/config"

Chef::Log.info("symlinking config files")
run "sudo ln -fs #{config.shared_path}/config/database.yml #{config.release_path}/config/database.yml"

run "sudo ln -fs #{config.shared_path}/config/google-apps.yml #{config.release_path}/config/google-apps.yml"

run "sudo ln -fs #{config.shared_path}/config/nginx.conf #{config.release_path}/config/nginx.conf"

Chef::Log.info("create logging")
run "mkdir -p #{config.shared_path}/log"
run "touch #{config.shared_path}/log/production.log"


node[:deploy].each do |application, deploy|
  app_root = "#{deploy[:deploy_to]}/current"
  execute "chmod -R g+rw #{app_root}" do
  end
  shared_root = "#{deploy[:deploy_to]}/shared"
  execute "chmod -R g+rw #{shared_root}" do
  end
end