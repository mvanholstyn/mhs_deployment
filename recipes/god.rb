namespace :god do
  task :configure do
    require 'erb'
    run "umask 02 && mkdir -p #{shared_path}/config"
    template = File.read(File.join(File.dirname(__FILE__), "..", "templates", "config", "god.god"))
    result = ERB.new(template).result(binding)
    put result, "#{shared_path}/config/god.god", :mode => 0644
  end
end
