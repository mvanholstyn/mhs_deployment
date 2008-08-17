require 'etc'
# You must set :application, :repository, and :server in your Capfile

# Sets the RAILS_ENV for this deployment. Default: staging
set(:rails_env, ENV["RAILS_ENV"] ? ENV["RAILS_ENV"].to_sym : :staging)

if branch = ENV["BRANCH"]
  set(:branch, branch)
end

set(:deploy_via, :remote_cache)

# Sets the server. This MUST be set.
# set(:server) { abort "Please specify the server to deploy to, set :server, 'example.com'" }
# role(:web)                  { server }
# role(:app)                  { server }
# role(:db, :primary => true) { server }

# Sets the user to deploy as. Default: #{application}
set(:user) { application }

set :scm, :git

# Sets the location to deploy to. Default: /var/www/#{application}/#{rails_env}
set(:deploy_to) { "/var/www/#{application}/#{rails_env}" }

# Sets the extra paths to symlink.
set(:symlinks, [])

set(:backups, [])
set(:backup_on_deploy, true)

set(:use_sudo, false)
