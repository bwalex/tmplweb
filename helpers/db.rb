require 'rubygems'
require 'data_mapper'
require 'dm-timestamps'
require 'erb'
include ERB::Util

DataMapper::Logger.new($stdout, :debug)

#DataMapper.setup(:default, 'sqlite:test.db')
DataMapper.setup(:default, 'sqlite::memory:')

class Post
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :title,      String,    :length => 128,
                                   :required => true    # A varchar type string, for short strings
  property :body,       Text,      :required => true     # A text block, for longer string data.
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :categorizations
  has n, :categories, :through => :categorizations
  

  def get_path
    created_at.strftime('%F') + "-" + title.gsub(/[\/\\]/, "-") + ".html"
  end

  def get_url
    url = url_encode(get_path)
  end
end


class Categorization
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime

  belongs_to :category
  belongs_to :post
end


class Category
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,    :length => 1..32,
                                   :required => true,
				   :unique => true,
				   :format =>  /[a-zA-Z0-9]+/

  has n, :categorizations
  has n, :posts,      :through => :categorizations

  def get_path
    name + ".html"
  end
end


class User
  include DataMapper::Resource

  property :id,         Serial
  property :user,       String,    :length => 3..32,
                                   :required => true,
                                   :unique => true

  property :email,      String,    :length => 6..128,
                                   :required => true,
                                   :format => :email_address,
                                   :unique => true

  property :name,       String,    :length => 2..64,
                                   :required => true

  property :password,   String,    :length => 64,
                                   :required => true
end


class Session
  include DataMapper::Resource
  property :session_id, String,    :key => true,
                                   :length => 64
  property :expires_at, DateTime,  :required => true

  belongs_to :user, :child_key => [ :uid ]
end


class MenuItem
  attr_accessor :classes
  @classes = ''

  include DataMapper::Resource
  property :id,        Serial
  property :url,       String,     :required => true
  property :text,      String,     :required => true
  property :place,     Integer,    :required => true
end

# XXX: add sidebar foo, probably with support for plugin macros
# XXX: add general support for plugin macros

DataMapper.finalize
DataMapper.auto_migrate!



MenuItem.create(:url => '\#', :text => 'Blog', :place => 2)
MenuItem.create(:url => '\#', :text => 'DragonFly', :place => 3)
MenuItem.create(:url => '\#', :text => 'Home', :place => 1)

Post.create(:title => 'The Glue Factory 1', :body => 'Body 1 test')
Post.create(:title => 'The Glue Factory 2', :body => 'Body 2 test')
Post.create(:title => 'The Glue Factory 3', :body => 'Body 3 test')
Post.create(:title => 'The Glue Factory 4', :body => 'Body 4 test')
Post.create(:title => 'The Glue Factory 5', :body => 'Body 5 test')
