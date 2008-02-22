namespace :backup do
  task :directory do
    ENV['BACKUP_DIR'] ||= 'backups'
  end
  
  task :version do
    ENV['BACKUP_VERSION'] ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  task :latest => :directory do
    last = Dir["#{ENV['BACKUP_DIR']}/*/"].sort.last
    ENV['BACKUP_VERSION'] ||= File.basename(last) if last
  end

  task :create do
    Rake::Task["db:backup:create"].invoke
    Rake::Task["assets:backup:create"].invoke
  end
  
  task :restore do
    Rake::Task["db:backup:restore"].invoke
    Rake::Task["assets:backup:restore"].invoke
  end
end