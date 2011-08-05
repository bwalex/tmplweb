require 'rubygems'
require 'json'
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

f = File.open("rhtml/blog-index-posts.rhtml")
rhtml = ERB.new(f.read)
f.close


Category.all().each do |category|
  category_html = ""
  # XXX: sort? :order => [ :created_at.desc ]
  category.posts.each do |post|
    category_html += rhtml.result(binding)
  end

  page = Page.new("Pages in category #{category.name}", "Pages in category #{category.name}", category_html)
  menuItems = MenuItem.all(:order => [ :place.asc ])

  html = main_tmpl.result(binding)
  f = File.open("out/category/"+category.get_path, File::WRONLY|File::CREAT|File::EXCL)
    f.write(html)
  f.close
end
