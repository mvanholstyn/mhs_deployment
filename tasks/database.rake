namespace :db do
  namespace :data do
    desc "Load seed fixtures (from db/fixtures) into the current environment's database."
    task :seed => :environment do
      require 'active_record/fixtures'
      Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end
    end
  end
  
  # Adding db:data:seed to be run automatically when db:migrate is run
  task :migrate do
    Rake::Task["db:data:seed"].invoke
  end

  desc "Run the mysql shell for the current environment using the configuration defined in database.yml"
  task :shell do
    configuration = YAML.load_file(File.join(RAILS_ROOT, 'config', 'database.yml'))[RAILS_ENV]
    case configuration["adapter"]
      when "mysql"
        command = ["mysql"]
        command << "-u#{configuration['username']}"   if configuration['username']
        command << "-p'#{configuration['password']}'" if configuration['password']
        command << "-h#{configuration['host']}"       if configuration['host']
        command << "-P#{configuration['port']}"       if configuration['port']
        command << configuration['database']          if configuration['database']
      when "postgresql"
        ENV['PGHOST']     = configuration["host"]     if configuration["host"]
        ENV['PGPORT']     = configuration["port"]     if configuration["port"]
        ENV['PGPASSWORD'] = configuration["password"] if configuration["password"]
        command = ["psql", "-U #{configuration['username']}", configuration['database']]
      when "sqlite"
        command = ["sqlite", configuration["database"]]
      when "sqlite3"
        command = ["sqlite3", configuration["database"]]
      else
        raise "not supported for this database type"
    end
    system command.join(" ")
  end
  
  namespace :backup do
    task :directory do
      ENV['BACKUP_DIR'] ||= 'backups'
    end
  
    task :latest => :directory do
      last = Dir["#{ENV['BACKUP_DIR']}/*/"].sort.last
      puts ENV['VERSION'] ||= File.basename(last) if last
    end
  
    task :environment => :directory do
      ENV['VERSION'] ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
      backup = "#{ENV['BACKUP_DIR']}/#{ENV['VERSION']}"
      FileUtils.mkdir_p backup
      ENV['FIXTURES_DIR'] = backup
      ENV['SCHEMA'] = "#{backup}/schema.rb"
    end
  
    task :schema => :environment do
      `cp db/schema.rb #{ENV['FIXTURES_DIR']}/`
    end
  
    task :create => [:environment, 'db:fixtures:dump', 'db:schema:dump']
  
    task :restore => [:latest, :environment, 'db:schema:load', 'db:fixtures:load']
  end
end
