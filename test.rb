require 'rubygems'
require 'erb'
require 'ostruct'
require 'htmlentities'
require 'helpers/page.rb'
require 'helpers/plugin.rb'

Dir["plugins/*.rb"].each{|x| load x }
# load 'plugins/linkedin-profile.rb'

f = File.open("rhtml/index.rhtml")
main_tmpl = ERB.new(f.read)
f.close


plugins = Plugin.registered_plugins

html = plugins["LinkedInProfile"].expand
#html = plugins["BlogIndex"].expand

page = Page.new("Blog Index", "Blog Index", html)
menuItems = MenuItem.all(:order => [ :place.asc ])

html = main_tmpl.result(binding)

f = File.open("out/test.html", File::WRONLY|File::CREAT|File::EXCL)
f.write(html)
f.close

