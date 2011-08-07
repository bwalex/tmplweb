#!/usr/bin/ruby
ENV['GEM_HOME'] = '/home/alexhorn/ruby/gems'
require "rubygems"

require "rack"
require "adminapp.rb"


class ApacheFixer
	def initialize(app); @app = app; end

	def call(env)
		env['SCRIPT_NAME'] = '/'
		puts env
		env['PATH_INFO'] = '/' + env['REQUEST_URI'].gsub(/.*\//, '') 
		env['PATH_INFO'] = env['PATH_INFO'][0..(env["PATH_INFO"].index("?")||0)-1]
		@app.call(env)
	end
end

Rack::Handler::CGI.run ApacheFixer.new(AdminApp)
