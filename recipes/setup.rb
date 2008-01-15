namespace :deploy do
  task :setup_extras, :except => { :no_release => true } do
    db.configure
    mongrel.cluster.configure
    
    # Copy over a virtual host config file
    # run "umask 02 && mkdir -p /etc/apache2/sites-available /etc/apache2/sites-enabled"
    # template = File.read(File.join(File.dirname(__FILE__), "..", "templates", "config", "virtual_host.conf"))
    # result = ERB.new(template).result(binding)
    # put result, "/etc/apache2/sites-available/#{application}-#{rails_env}.conf", :mode => 0644
    # run "rm -f /etc/apache2/sites-enabled/#{application}-#{rails_env}.conf && ln -s /etc/apache2/sites-available/#{application}-#{rails_env}.conf /etc/apache2/sites-enabled/#{application}-#{rails_env}.conf"
  end
  after "deploy:setup", "deploy:setup_extras"
end