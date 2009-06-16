# namespace :crontab do
#   task :remove, :roles => :db, :only => { :primary => true } do
#     run "crontab -r"
#   end
#   after "deploy:web:disable", "crontab:remove"
#   
#   task :install, :roles => :db, :only => { :primary => true } do
#     run "crontab #{current_path}/config/crontab"
#   end
#   after "deploy:web:enable", "crontab:install"
# end

# TODO: Make this remove when starting, add when finished?
namespace :crontab do
  task :install, :roles => :db do
    run "cd #{release_path} && whenever --set environment=#{rails_env} --update-crontab #{application}-#{rails_env}-#{branch}"
  end
end
after "deploy:symlink", "crontab:install"
