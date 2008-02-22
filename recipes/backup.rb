namespace :backup do
  desc "Creates a backup of the database and assets."
  task :create, :roles => :db, :only => {:primary => true} do
    ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
    run "cd #{current_path} && rake #{rails_env} backup:create BACKUP_DIR=#{ENV['BACKUP_DIR']} BACKUPS=#{backups.join(',')}"
  end
  
  desc "Creates a backup of the database and assets."
  task :restore, :roles => :db, :only => {:primary => true} do
    ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
    run "cd #{current_path} && rake #{rails_env} backup:restore BACKUP_DIR=#{ENV['BACKUP_DIR']} BACKUPS=#{backups.join(',')}"
  end
end