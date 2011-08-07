#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'user.rb'
require '../helpers/db.rb'
require '../helpers/recursive-openstruct.rb'
require '../helpers/theme-config.rb'

class AdminApp < Sinatra::Base
  set :sessions => true
  set :session_secret, 'adminapp.rb'

  register do
    def auth (type)
      condition do
        redirect "/login" unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
      @user != nil
    end
  end

  before do
    @user = User.check(session[:user_id])
  end

#  get '*' do |n|
#    "Hello #{n}!"
#  end

  get '/test' do
    "Hello from Sinatra!"
  end

  get '/' do
    if session[:user_id] == nil
      'Hi world!'
    else
      "Hi "+session[:user_id]
    end
  end

  not_found do
    "This is nowhere to be found!"
  end

  get "/protected", :auth => :user do
    "Hello, #{@user.name}."
  end

  get "/login" do
    '<form action="login" method="post"><input type="submit"/></form>'
  end

  get "/newpost" do
    f = File.open("rhtml/newpost.rhtml")
    tmpl = ERB.new(f.read)
    f.close
    tmpl.result
  end

  post "/newpost" do
    json = JSON.parse(params[:sidebars])
    post = Post.create(
      :title    => params[:title],
      :body     => params[:body]
    )
  
    json.each do |sidebar|
      sb = post.sidebars.new(
        :title    => sidebar["title"],
        :content  => sidebar["content"]
      )

      place = 0
      sidebar["elements"].each do |elem|
        sb.sidebarelements.new(
          :url    => elem["link"],
          :text   => elem["text"],
          :place  => ++place
        )
      end
      sb.save
    end
    ret = post.save
    "Posted!"
    YAML::dump(ret)
  end

  post "/login" do
    session[:user_id] = User.authenticate(params)
    'All ok! authed!' + session[:user_id]
  end

  get "/logout" do
    session[:user_id] = nil
  end

end

