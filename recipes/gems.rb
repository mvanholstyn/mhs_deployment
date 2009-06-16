# namespace :gems do
#   task :build do
#     run "cd #{release_path} && rake #{rails_env} gems:build"
#   end
#   after "deploy:update_code", "gems:build"
#
#   # TODO: Make this sudo so bin's are installed in the right place, or add this to .profile
#   # # set PATH so it includes user's private gem bin if it exists
#   # if [ -d "$HOME/.gem/ruby/1.8/bin" ] ; then
#   #   PATH="$HOME/.gem/ruby/1.8/bin:$PATH"
#   # fi
#   task :install do
#     run "cd #{release_path} && rake #{rails_env} gems:install"
#   end
#   after "deploy:update_code", "gems:install"
# end
