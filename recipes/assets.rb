namespace :assets do
  namespace :backup do
    desc "Creates a backup of the assets."
    task :create, :roles => :db, :only => {:primary => true} do
      ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
      run "cd #{current_path} && rake #{rails_env} assets:backup:create BACKUP_DIR=#{ENV['BACKUP_DIR']} BACKUPS=#{backups.join(',')}"
    end
    
    desc "Restores a backup of the assets."
    task :restore, :roles => :db, :only => {:primary => true} do
      ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
      run "cd #{current_path} && rake #{rails_env} assets:backup:restore BACKUP_DIR=#{ENV['BACKUP_DIR']} BACKUPS=#{backups.join(',')}"
    end
  end
end