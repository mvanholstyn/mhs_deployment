require 'etc'
require 'mongrel_cluster/recipes'

set :application, "example"
set :repository, "http://example.com/svn/#{application}/#{version}"

role :web, "www.example.com"
role :app, "www.example.com"
role :db,  "www.example.com", :primary => true

set :rails_env, ENV["RAILS_ENV"] ? ENV["RAILS_ENV"].to_sym : :development
set :version, ENV["VERSION"] ? "tags/#{ENV["VERSION"]}" : :trunk

set :mongrel_conf, "/etc/mongrel_cluster/#{application}/#{rails_env}.yml"
set :user, application
set :svn_username, Etc.getlogin
set :keep_releases, 10
set :deploy_to, "/var/www/#{application}/#{rails_env}/"

set :symlinks, %w{ config/database.yml }

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

# desc <<DESC
# An imaginary backup task. (Execute the 'show_tasks' task to display all
# available tasks.)
# DESC
# task :backup, :roles => :db, :only => { :primary => true } do
#   # the on_rollback handler is only executed if this task is executed within
#   # a transaction (see below), AND it or a subsequent task fails.
#   on_rollback { delete "/tmp/dump.sql" }
# 
#   run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
#     ch.send_data "thepassword\n" if out =~ /^Enter password:/
#   end
# end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

# task :helper_demo do
#   buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
#   put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
#   delete "#{shared_path}/system/maintenance.html"
# end

desc "A task demonstrating the use of transactions."
task :deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
  cleanup
end

desc <<-DESC
Update the 'current' symlink to point to the latest version of
the application's code.
DESC
task :symlink, :except => { :no_release => true } do
  on_rollback { run "ln -nfs #{previous_release} #{current_path}" }
  run "ln -nfs #{current_release} #{current_path}"
  symlinks.each do |symlink|
    run "ln -nfs #{shared_path}/#{symlink} #{current_path}/#{symlink}"
  end
end

task :fixtures, :roles => :db, :only => { :primary => true } do
  fixtures = ENV["FIXTURES"] ? "FIXTURES=#{ENV["FIXTURES"]}" : ""
  run "cd #{current_path} && " +
      "#{rake} RAILS_ENV=#{rails_env} db:fixtures:load #{fixtures}"
end
