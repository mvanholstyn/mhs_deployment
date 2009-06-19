# You must set :application, :repository, and :server in your Capfile

# Sets the server. This MUST be set.
# set(:server) { abort "Please specify the server to deploy to, set :server, 'example.com'" }
# role(:web)                  { server }
# role(:app)                  { server }
# role(:db, :primary => true) { server }

set(:rails_env, :staging)
set(:scm, :git)
set(:deploy_via, :remote_cache)
set(:branch, "master")
set(:user) { application }
set(:deploy_to) { "/home/#{user}/#{application}/#{rails_env}/#{branch}" }
set(:symlinks, [])
set(:backups, [])
set(:backup_on_deploy, true)
set(:use_sudo, false)

ssh_options[:forward_agent] = true
