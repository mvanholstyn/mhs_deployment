namespace :backup do
  task :create do
    run "cd #{current_path} && rake #{rails_env} backup:create BACKUP_DIR=#{shared_path}/backups BACKUPS=#{backups.join(',')}"
  end
end