require 'rubygems'
require 'json'
require 'erb'
require 'ostruct'
require 'htmlentities'
require 'helpers/plugin.rb'
require 'helpers/db.rb'

## Read current configuration
#f = File.open("config/blog-config.json", "r")
#config = JSON.parse(f.read)
#f.close

f = File.open("rhtml/blog-index-posts.rhtml")
template = f.read
f.close

rhtml = ERB.new(template)

Category.all().each do |category|
  category_html = ""
  # XXX: sort? :order => [ :created_at.desc ]
  category.posts.each do |post|
    category_html += rhtml.result(binding)
  end

  f = File.open("out/category/"+category.get_path, File::WRONLY|File::CREAT|File::EXCL)
    f.write(category_html)
  f.close
end
