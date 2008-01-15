namespace :db do
  desc "Run the mysql shell for the current environment using the configuration defined in database.yml"
  task :shell, :roles => :db, :only => { :primary => true } do
    input = ''
    run "cd #{current_path} && rake #{rails_env} db:shell" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
  
  desc "Creates a database.yml file in shared/config. It will prompt for the database password."
  task :configure do
    require 'erb'
    run "umask 02 && mkdir -p #{shared_path}/config"
    template = File.read(File.join(File.dirname(__FILE__), "..", "templates", "config", "database.yml"))
    result = ERB.new(template).result(binding)
    put result, "#{shared_path}/config/database.yml", :mode => 0644
  end
  
  namespace :data do
    desc "Load seed fixtures (from db/fixtures) into the current environment's database."
    task :seed, :roles => :db, :only => { :primary => true } do
      run "cd #{current_path} && rake #{rails_env} db:data:seed"
    end
  end
  
  namespace :backup do
    desc "Creates a back of the database."
    task :create, :roles => :db, :only => {:primary => true} do
      run "cd #{current_path} && rake #{rails_env} db:backup:create BACKUP_DIR=#{shared_path}/backups"
    end
    
    # task :remote_to_local, :roles => :db, :only => {:primary => true} do
    #   latest = capture("cd #{current_path}; rake -s backup:latest BACKUP_DIR=#{backup_path}").strip
    #   run "tar -C #{backup_path} -czf #{backup_path}/#{latest}.tar.gz #{latest}"
    #   `mkdir -p backups`
    #   get "#{backup_path}/#{latest}.tar.gz", "backups/#{latest}.tar.gz"
    #   `tar -C backups -zxf backups/#{latest}.tar.gz`
    #   run "rm #{backup_path}/#{latest}.tar.gz"
    #   `rm backups/#{latest}.tar.gz`
    #   `rake backup:restore`
    # end
  end
end