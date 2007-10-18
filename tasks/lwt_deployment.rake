["production", "staging"].each do |environment|
  desc "Runs the following task(s) in the #{environment} environment" 
  task environment do
    RAILS_ENV = ENV['RAILS_ENV'] = environment
  end
end

namespace :db do
  desc "Run the mysql shell for the current environment using the configuration defined in database.yml"
  task :shell do
    configuration = YAML.load_file(File.join(RAILS_ROOT, 'config', 'database.yml'))[RAILS_ENV]
    command = ["mysql"]
    command << "-u#{configuration['username']}" if configuration['username']
    command << "-p#{configuration['password']}" if configuration['password']
    command << "-h#{configuration['host']}"     if configuration['host']
    command << "-P#{configuration['port']}"     if configuration['port']
    command << configuration['database']        if configuration['database']
  
    system command.join(" ")
  end
end