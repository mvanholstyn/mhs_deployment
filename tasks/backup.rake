namespace :backup do
  task :directory do
    ENV['BACKUP_DIR'] ||= 'backups'
  end
  
  task :version do
    ENV['BACKUP_VERSION'] ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
end