namespace :db do
  # desc "Run the mysql shell for the current environment using the configuration defined in database.yml"
  # task :shell, :roles => :db, :only => { :primary => true } do
  #   input = ''
  #   run "cd #{current_path} && rake #{rails_env} db:shell" do |channel, stream, data|
  #     next if data.chomp == input.chomp || data.chomp == ''
  #     print data
  #     channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  #   end
  # end
  
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
    desc "Creates a backup of the database."
    task :create, :roles => :db, :only => {:primary => true} do
      ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
      run "cd #{current_path} && rake #{rails_env} db:backup:create BACKUP_DIR=#{ENV['BACKUP_DIR']}"
    end
    
    desc "Restores a backup of the database."
    task :restore, :roles => :db, :only => {:primary => true} do
      ENV['BACKUP_DIR'] ||= "#{shared_path}/backups"
      run "cd #{current_path} && rake #{rails_env} db:backup:restore BACKUP_DIR=#{ENV['BACKUP_DIR']}"
    end
  end
end
