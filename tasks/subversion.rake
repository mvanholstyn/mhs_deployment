namespace :svn do
  desc "Display svn messages. (date=today user=username)"
  task :messages => :environment do
    date = ENV['date'] ? Chronic.parse(ENV['date']).to_date : Date.today
      
    messages = svn_messages_since(date, ENV['user'])
    
    if messages.empty?
      puts "No changes since #{date}..."
    else
      puts messages.map { |m| "* #{m}\n" }
    end
  end
end

def svn_messages_since(start_date, user = nil)
  require 'rexml/document'
  require 'chronic'

  puts "Retrieving svn messages since #{start_date}..."
  doc = REXML::Document.new(`svn log --xml #{RAILS_ROOT} -r {#{start_date}}:HEAD`)

  messages = []
  doc.elements.each('log/logentry') do |logentry|
    # Stip blank messages
    message = logentry.elements['msg'].text.to_s.strip
    next if message.blank?

    # Skip messages from other users if a specific user is given
    author = logentry.elements['author'].text
    next if user and author != user
    
    # Skip messages before the start date
    date = Chronic.parse(logentry.elements['date'].text[0,10]).to_date
    next if date < start_date

    messages << "#{date}: #{message} (#{author})"
  end    
  messages.uniq
end

# namespace :svn do
#   desc "See a list of the svn messages.  Filter them by user with u=user (ex: u=domelia)."
#   task(:messages) do
#     require File.expand_path(File.dirname(__FILE__) + "/../../config/environment.rb") 
#     raise "Please specify a start revision.\nExample usage: svn:messages r=473" unless ENV['r']
#     
#     puts "* " + svn_messages(ENV['r']).join("\n* ")  
#   end
# 
#   desc "See a list of the svn messages since the last deployment."
#   task(:deployment_message) do
#     revision = `cap svn:latest_commit -q`.strip
#     ENV['r'] = (`cap svn:latest_deployment -q`.strip.to_i + 1).to_s
#     puts "Deployment (Revision #{revision})"
#     puts "I deployed the latest. It includes:"
#     puts 
#     Rake::Task['svn:messages'].invoke
#     puts
#   end
#   
#   desc "Add all new files to subversion"
#   task :add do
#      system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
#   end
# end