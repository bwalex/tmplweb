require 'rubygems'
#require 'json'
require 'erb'
require 'ostruct'
require 'htmlentities'
require 'helpers/plugin.rb'
require 'helpers/db.rb'
require 'helpers/theme-config.rb'

class BlogIndex < Plugin
  def expand
    ## Read current configuration
    #f = File.open("config/blog-config.json", "r")
    #config = JSON.parse(f.read)
    #f.close

    f = File.open("rhtml/blog-index-posts.rhtml")
    template = f.read
    f.close

    rhtml = ERB.new(template)
 
    blog_index_html = ""
    Post.all(:offset => 0, :limit => 10, :order => [ :created_at.desc ]).each do |post|
      blog_index_html += rhtml.result(binding)
    end

    return blog_index_html
  end
end
