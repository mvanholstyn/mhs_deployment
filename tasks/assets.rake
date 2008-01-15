namespace :assets do
  namespace :backup do  
    desc "Creates a backup of the assets."
    task :create do
      backup_directory = "#{backup.directory}/#{backup.version}"

      backups.each do |backup|
        FileUtils.mkdir_p "#{backup_directory}/#{backup}"
        FileUtils.cp_r "#{current_path}/#{backup}", "#{backup_directory}/#{backup}"
      end
    end
  end
end
