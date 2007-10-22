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
end

namespace :svn do
  desc "Display svn messages. (date=today user=username)"
  task :messages => :environment do
    date = ENV['date'] ? Chronic.parse(ENV['date']).to_date : Date.today
      
    messages = svn_messages_since(date, ENV['user'])
    
    if messages.empty?
      puts "No changes since #{date}..."
    else
      puts messages.map { |m| "* #{m}\n" }
    end
  end
end

def svn_messages_since(start_date, user = nil)
  require 'rexml/document'
  require 'chronic'

  puts "Retrieving svn messages since #{start_date}..."
  doc = REXML::Document.new(`svn log --xml #{RAILS_ROOT} -r {#{start_date}}:HEAD`)

  messages = []
  doc.elements.each('log/logentry') do |logentry|
    # Stip blank messages
    message = logentry.elements['msg'].text.to_s.strip
    next if message.blank?

    # Skip messages from other users if a specific user is given
    author = logentry.elements['author'].text
    next if user and author != user
    
    # Skip messages before the start date
    date = Chronic.parse(logentry.elements['date'].text[0,10]).to_date
    next if date < start_date

    messages << "#{date}: #{message} (#{author})"
  end    
  messages.uniq
end

# TODO: SVN integration
namespace :gems do
  task :freeze do
    raise "No gem specified" unless gem_name = ENV['GEM']

    require 'rubygems'
    require 'activesupport'
    Gem.manage_gems
    
    if version = ENV['VERSION']
      gem = Gem.cache.search(gem_name, "= #{version}").first
    else
      gem = Gem.cache.search(gem_name).sort_by(&:version).last
    end
    
    if gem
      version ||= gem.version.version
    else
      raise "Could not find the gem '#{gem_name}' #{version}"
      # TODO: Auto install the gem?
      # tmp_dir = File.join(RAILS_ROOT, 'tmp', 'gems')
      # begin
      #   if version
      #     Gem::GemRunner.new.run ["install", "#{gem_name}", "-v", "#{version}", "-i", "#{tmp_dir}/gems", "--no-rdoc", "--include-dependencies"]
      #   else
      #     Gem::GemRunner.new.run ["install", "#{gem_name}", "-i", "#{tmp_dir}", "--no-rdoc", "--include-dependencies"]
      #   end
      # rescue
      #   puts "ERROR. Failed to download #{gem_name}."
      #   exit(1)
      # end
      # ENV["GEM_HOME"] = "#{tmp_dir}/gems"
      # gem = Gem::SourceIndex.from_installed_gems("#{tmp_dir}/gems/specifications").search(gem_name).first
    end
    
    vendor_gems_directory = File.join(RAILS_ROOT, 'vendor', 'gems')
    mkdir_p vendor_gems_directory
    
    chdir vendor_gems_directory do
      # TODO: Remove old versions...
      gem.dependencies.each do |dependency|
        Gem::GemRunner.new.run ["unpack", "-v", "#{dependency.version_requirements}", dependency.name ]
      end
      Gem::GemRunner.new.run ["unpack", "-v", "=#{gem.version}", gem_name ]
    end
  end

  task :unfreeze do
    raise "No gems specified" unless gem_names = ENV['GEMS']
    Dir[File.join(RAILS_ROOT, *%W[vendor gems {#{gem_names}}-*])].each do |gem_directory|
      rm_rf gem_directory
    end
  end

  task :update do
    require 'rubygems'
    require 'activesupport'
    Gem.manage_gems
    
    Dir[File.join(RAILS_ROOT, *%w[vendor gems *])].each do |gem_directory|
      match = File.basename(gem_directory).match(/^(.*)-(\d+(?:\.\d+)*)$/)
      gem_name, version = match[1], match[2]
      
      if newest_gem = Gem.cache.search(gem_name, "> #{version}").sort_by(&:version).last
        ENV['GEM'] = gem_name
        Rake::Task["gems:freeze"].invoke
      end
    end
  end
end





# This class is stored separately & included, of course. It'll all work in the same file for now, though.
class VersionError < Exception
  attr :required_version
  attr :installed_version
  
  def initialize(required,installed)
    @required_version = required
    @installed_version = installed
  end
end

# Formatted as package name, friendly version, command to execute, successful regex, version regex
@dependancies = [
  ['ruby',      '1.8.4 or 1.8.5', 'ruby -v',                                                          /ruby (1\.8\.[4-5])/,         /\d\.\d\.\d/],
  ['rake',      '0.x.x',          'rake --version',                                                   /rake, version (\d\.\d\.\d)/, /\d\.\d\.\d/],
  ['python',    '2.4.x',          'python -V',                                                        /Python (2\.4\.\d)/,          /\d\.\d\.\d/],
  ['pyro',      '3.x',            'python -c "import Pyro.core; print Pyro.core.constants.VERSION"',  /3\.\d/,                      /\d\.\d/],
  ['pil',       '1.1.x',          'python -c "import Image; print Image.VERSION"',                    /1\.1\.\d/,                   /\d\.\d\.\d/],
  ['mysql',     '5.0.x',          'mysql -V',                                                         /Distrib (5\.0\.\d+)/,        /\d\.\d\.\d+/],
  ['lighttpd',  '1.4.x',          'lighttpd -v',                                                      /lighttpd-(1\.4\.\d+)/,       /\d\.\d\.\d+/],
]

namespace :dependencies do
  desc ""
  task :check do
    require 'activesupport'
    require 'colored'
  
    installed = []
    uninstalled = []
  
    @dependancies.each do |dep|
      data = `#{dep[2]} 2>&1`
    
      if data =~ /command not found/
        uninstalled << "#{dep[0].upcase} is not installed (or isn't in your path). Please install version #{dep[1]}."
      else
        if not data =~ dep[3]
          if data =~ dep[4]
            uninstalled << "#{dep[0].upcase} version incorrect! #{dep[1]} required, but found #{$~[0]}"
          else
            uninstalled << "#{dep[0].upcase} version incorrect! #{dep[1]} required, but found undetermined version"
          end
        else
          installed << "#{dep[0].upcase} (#{dep[1]}) is installed correctly."
        end
      end
    end
  
    puts installed.map(&:green)
    puts uninstalled.map(&:red)
  end
end