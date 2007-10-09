load File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'lwt_deployment', 'recipes')

set :application, "example"
set :repository_host, "svn.example.com"

role :web, "example.com"
role :app, "example.com"
role :db, "example.com", :primary => true
