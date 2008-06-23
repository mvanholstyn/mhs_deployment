# mongrel_rails start -d -e production -a 127.0.0.1 -c /var/www/wingnut/production/current --user wingnut --group wingnut -p 8000 -P tmp/pids/mongrel.8000.pid  -l log/mongrel.8000.log
# mongrel_rails start -d -e production              -c /var/www/wingnut/production/current                                -p 8003 -P tmp/pids/mongrel.8003.pid  -l log/mongrel.8003.log

# run with:  god -c /path/to/god.god

God::Contacts::Email.message_settings = {
  :from => "god"
}
 
God::Contacts::Email.server_settings = {
  :address => 'localhost', :port => 25
}

God.contact(:email) do |c|
  c.name  = 'god'
  c.email = 'mvanholstyn@mutuallyhuman.com'
end

[<%= mongrel.ports.join(',') %>].each do |port|
  God.watch do |w|
    w.name = "<%= rails_env %>-mongrel-#{port}"
    w.group = "<%= rails_env %>-mongrels"
    w.uid = "<%= mongrel_user %>"
    w.gid = "<%= mongrel_group %>"
    w.interval = 30.seconds
    w.start = "mongrel_rails start -d -e <%= mongrel_environment %> -c <%= current_path %> -p #{port} -P tmp/pids/mongrel.#{port}.pid -l log/mongrel.#{port}.log"
    w.stop = "mongrel_rails stop -P <%= current_path %>/tmp/pids/mongrel.#{port}.pid"
    w.restart = "mongrel_rails restart -P <%= current_path %>/tmp/pids/mongrel.#{port}.pid"
    w.pid_file = File.join("<%= current_path %>", "tmp/pids/mongrel.#{port}.pid")
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