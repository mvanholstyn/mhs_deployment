[:production, :staging].each do |environment|
  desc "Runs the following task(s) in the #{environment} environment" 
  task environment do
    set(:rails_env, environment)
  end
end

desc "Setup deployment to localhost"
task :localhost do
  role :web, "localhost"
  role :app, "localhost"
  role :db, "localhost", :primary => true
  set :rails_env, :production
end

Dir[File.join(File.dirname(__FILE__), *%w[.. .. .. .. config deploy *.rb])].each do |deploy_file|
  task File.basename(deploy_file).gsub(".rb", "") do
    load deploy_file
  end
end