#Rename this to deploy.rb before you try to use it!
default_run_options[:shell] = '/bin/bash --login'
default_run_options[:pty] = true
load "deploy/assets"
require "bundler/capistrano"

set :user, "nulogy"
set :password, "Nulogy4Ever"
set :application, "richard"
set :repository,  "readonlycode@porcupine.nu:/home/code/richard.git"
set :scm, :git
set :scm_verbose, true
set :deploy_to, "/data/#{application}"
set :rails_env, 'production'

ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true
ssh_options[:port] = 22

task :production do
    role :web, "192.168.50.37:22"                          # Your HTTP server, Apache/etc
    role :app, "192.168.50.37:22"                          # This may be the same as your `Web` server
    role :db,  "192.168.50.37:22", :primary => true        # This is where Rails migrations will run, NOT NECESSARILY where the database actually is
end

task :qa do
  role :web, "192.168.50.37:22"                          # Your HTTP server, Apache/etc
  role :app, "192.168.50.37:22"                          # This may be the same as your `Web` server
  role :db,  "192.168.50.37:22", :primary => true        # This is where Rails migrations will run, NOT NECESSARILY where the database actually is

  set :application, 'qa-richard'
  set :deploy_to, "/data/#{application}"
end

namespace :deploy do
  before "deploy:assets:precompile", "deploy:database_yml"
  after "deploy:create_symlink", "deploy:create_logspace"
  after "deploy:create_logspace", "deploy:nginx_config"
  after "deploy:restart", "deploy:cleanup"

  task :nginx_config, :roles => :web, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/config"
    run "#{try_sudo} cp -f #{current_path}/config/nginx.conf #{shared_path}/config/nginx.conf"
    run "#{try_sudo} ln -fs #{shared_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}.conf"
  end

  task :database_yml, :roles => :web, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  task :create_logspace, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/log"
    run "touch #{shared_path}/log/production.log"
  end

  desc "Restart Passenger gracefully"
  task :apprestart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Reload Nginx config changes"
  task :webrestart, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} service nginx reload"
  end

  task :start do ; end
  task :stop do ; end
  task :restart do
    webrestart
    apprestart
  end

  # Precompile assets
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    end
  end

  task :cleanup, :except => {:no_release => true} do
    count = fetch(:keep_releases, 5).to_i
    try_sudo "ls -1dt #{releases_path}/* | tail -n +#{count + 1} | xargs rm -rf"
  end
end