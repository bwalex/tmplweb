require 'helpers/plugin.rb'

# Dir["#{PLUGIN_DIR}/*.rb"].each{|x| load x }
load 'plugins/linkedin-profile.rb'



plugins = Plugin.registered_plugins

puts plugins["LinkedInProfile"].expand
