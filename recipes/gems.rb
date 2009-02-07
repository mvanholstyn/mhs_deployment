namespace :gems do
  task :build do
    run "cd #{release_path} && rake #{rails_env} gems:build"
  end
end
after "deploy:update_code", "gems:build"