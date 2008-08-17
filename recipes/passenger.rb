namespace :passenger do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
