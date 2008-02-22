namespace :assets do
  namespace :backup do  
    desc "Creates a backup of the assets."
    task :create => ["backup:directory", "backup:version"] do
      backup_directory = "#{ENV['BACKUP_DIR']}/#{ENV['BACKUP_VERSION']}"

      ENV["BACKUPS"].to_s.split(",").each do |backup|
        target = backup
        destination = "#{backup_directory}/#{backup}"
        if File.exist?(target)
          FileUtils.mkdir_p File.dirname(destination)
          FileUtils.cp_r target, destination
        end
      end
    end
    
    desc "Restores a backup of the assets."
    task :restore => ["backup:directory", "backup:latest"] do
      backup_directory = "#{ENV['BACKUP_DIR']}/#{ENV['BACKUP_VERSION']}"

      ENV["BACKUPS"].to_s.split(",").each do |backup|
        target = "#{backup_directory}/#{backup}"
        destination = backup
        if File.exist?(target)
          if File.symlink?(destination)
            Dir["#{destination}/*"].each { |file| FileUtils.rm_rf file }
            Dir["#{target}/*"].each { |file| FileUtils.cp_r file, destination }
          else
            FileUtils.rm_rf destination
            FileUtils.mkdir_p File.dirname(destination)
            FileUtils.cp_r target, destination
          end
        end
      end      
    end
  end
end
