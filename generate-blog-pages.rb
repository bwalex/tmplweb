require 'rubygems'
#require 'json'
require 'erb'
require 'ostruct'
require 'htmlentities'
require 'helpers/page.rb'
require 'helpers/plugin.rb'
require 'helpers/db.rb'
require 'helpers/theme-config.rb'


f = File.open("rhtml/index.rhtml")
main_tmpl = ERB.new(f.read)
f.close

f = File.open("rhtml/single-post.rhtml")
rhtml = ERB.new(f.read)
f.close




Post.all.each do |post|
  page = Page.new(post.title, post.title, rhtml.result(binding))
  menuItems = MenuItem.all(:order => [ :place.asc ])
  page_url = post.get_url
  page_uuid = post.get_uuid
  sidebar = post.sidebars

  html = main_tmpl.result(binding)

  f = File.open("out/posts/" + post.get_path, File::WRONLY|File::CREAT|File::EXCL)
  f.write(html)
  f.close
end
