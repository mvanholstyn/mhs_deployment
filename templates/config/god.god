# mongrel_rails start -d -e production -a 127.0.0.1 -c /var/www/wingnut/production/current --user wingnut --group wingnut -p 8000 -P tmp/pids/mongrel.8000.pid                                     -l log/mongrel.8000.log
# mongrel_rails start -d -e production              -c /var/www/wingnut/production/current                                -p 8003 -P /var/www/wingnut/production/current/tmp/pids/mongrel.8003.pid

# run with:  god -c /path/to/god.god

APPLICATION = <%= application.inspect %>
SERVER = <%= "TODO".inspect %>
RAILS_ENV = <%= rails_env.inspect %>
RAILS_ROOT = <%= current_path.inspect %>
PORTS = <%= 
  ports = []
  mongrel_servers.times do |i| 
    ports << mongrel_port + i
  end
  ports.inspect
%>
MONGREL_ENV = <%= mongrel_environment.inspect %>

God::Contacts::Email.message_settings = {
  :from => "god@#{SERVER}"
}
 
God::Contacts::Email.server_settings = {
  :address => 'localhost',
  :port => 25,
  :domain => SERVER
}

God.contact(:email) do |c|
  c.name  = 'god'
  c.email = 'mvanholstyn@mutuallyhuman.com'
end

# Watches for Trunk mongrels
PORTS.each do |port|
  God.watch do |w|
    w.name = "#{RAILS_ENV}-mongrel-#{port}"
    w.group = "#{RAILS_ENV}-mongrels"
    w.uid = APPLICATION
    w.gid = APPLICATION
    w.interval = 30.seconds
    w.start = "mongrel_rails start -c #{RAILS_ROOT} -p #{port} -e #{MONGREL_ENV} -P #{RAILS_ROOT}/tmp/pids/mongrel.#{port}.pid -d"
    w.stop = "mongrel_rails stop -P #{RAILS_ROOT}/tmp/pids/mongrel.#{port}.pid"
    w.restart = "mongrel_rails restart -P #{RAILS_ROOT}/tmp/pids/mongrel.#{port}.pid"
    w.pid_file = File.join(RAILS_ROOT, "tmp/pids/mongrel.#{port}.pid")
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds
 
    w.behavior(:clean_pid_file)

    # Start if process is not running
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running  = false
        c.notify   = 'god'
      end
    end
 
    # Start if memory usage is high
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above  = 150.megabytes
        c.times  = [3, 5]
        c.notify = 'god'
      end
 
      restart.condition(:cpu_usage) do |c|
        c.above  = 50.percent
        c.times  = 5
        c.notify = 'god'
      end
    end

    # Prevent "flapping"
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state     = [:start, :restart]
        c.times        = 50
        c.within       = 5.minute
        c.transition   = :unmonitored
        c.retry_in     = 10.minutes
        c.retry_times  = 5
        c.retry_within = 2.hours
        c.notify       = 'god'
      end
    end
  end
end