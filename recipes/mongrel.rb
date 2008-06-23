namespace :mongrel do
  task :ports do
    ports = []
    mongrel_servers.times do |i| 
      ports << mongrel_port + i
    end
    ports
  end
end