load File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'lwt_deployment', 'recipes')

set :application, "example"
set :repository_host, "svn.example.com"

# Used for web.disable and web.enable
role :web, "example.com"
# Used for deploy.start, deploy.stop, deploy.restart
role :app, "example.com"
# Used for deploy.migrate
role :db, "example.com", :primary => true
