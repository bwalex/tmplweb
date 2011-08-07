require 'rubygems'
require 'data_mapper'
require 'dm-timestamps'
require 'erb'
require 'digest/sha2'
include ERB::Util

#DataMapper::Logger.new($stdout, :debug)

#DataMapper.setup(:default, 'sqlite:test.db')
DataMapper.setup(:default, 'sqlite::memory:')

class Post
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :title,      String,    :length => 128,
                                   :required => true    # A varchar type string, for short strings
  property :body,       Text,      :required => true     # A text block, for longer string data.
  property :is_post,    Boolean,   :default  => true
  property :comments_disabled, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :sidebarcontexts
  has n, :sidebars, :through => :sidebarcontexts

  has n, :categorizations
  has n, :categories, :through => :categorizations
  

  def get_path
    created_at.strftime('%F') + "-" + title.gsub(/[\/\\]/, "-") + ".html"
  end

  def get_short_body
    #short = body[0,600]
    short = body
  end

  def get_url
    url = url_encode(get_path)
  end

  def get_uuid
    bar = Digest::SHA2.new << get_url
    uuid = bar.to_s
  end
end


class Sidebarcontext
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime

  belongs_to :sidebar
  belongs_to :post
end


class Sidebar
  include DataMapper::Resource
  property :id,        Serial
  property :title,     String,     :required => true
  property :place,     Integer,    :default => 0
  property :content,   Text
  
  has n, :sidebarelements

  has n, :sidebarcontexts
  has n, :posts, :through => :sidebarcontexts
end


class Sidebarelement
  include DataMapper::Resource
  property :id,        Serial
  property :url,       String,     :required => true
  property :text,      String,     :required => true
  property :place,     Integer,    :default => 0
 
  belongs_to :sidebar
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
				   :format =>  /[a-zA-Z0-9 ]+/

  has n, :categorizations
  has n, :posts,      :through => :categorizations

  def get_path
    name.gsub(/[\/\\]/, "-") + ".html"
  end
  
  def get_url
    url = url_encode(get_path)
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



MenuItem.create(:url => '#', :text => 'Blog', :place => 1)
MenuItem.create(:url => '#', :text => 'About', :place => 3)
MenuItem.create(:url => '#', :text => 'DragonFly', :place => 4)
MenuItem.create(:url => '#', :text => 'Projects', :place => 5)

post = Post.create(:title => 'The Glue Factory 1', :body => '
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam nec dui volutpat tortor viverra pulvinar non in sem. Pellentesque vitae sem erat. Integer urna tellus, ornare ac sagittis in, pretium non orci. Donec venenatis varius feugiat. Fusce gravida volutpat pharetra. Suspendisse potenti. Nullam eget tortor est. Fusce adipiscing, risus vitae pellentesque convallis, metus neque condimentum leo, vel pretium sem sem sed magna. Pellentesque blandit nisi interdum orci tristique tincidunt. Pellentesque at ultricies elit. Aliquam sed mauris sed neque luctus varius nec eu est. Vestibulum erat metus, blandit sit amet hendrerit ac, volutpat vitae tortor. Cras vehicula, ligula nec tempor venenatis, odio sem pretium diam, et interdum diam justo sit amet diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Integer sed lectus vitae justo interdum blandit. Duis non lectus felis. Aenean facilisis tincidunt erat ac placerat. Vestibulum ac urna magna.
</p>
<p>Nullam ornare, velit vel posuere sagittis, ante nibh commodo nulla, quis porttitor est mauris dictum diam. Suspendisse in sagittis odio. Donec venenatis nisl a mauris rhoncus hendrerit. In semper volutpat eros, nec consectetur justo aliquet venenatis. Mauris vel orci nunc. Sed dignissim dictum enim, quis volutpat metus varius ut. Cras eget velit sem, in aliquet magna. Aenean placerat interdum aliquet. Quisque vitae mi sem, et viverra dui. Cras vel erat sem, sed tempor libero. Vestibulum laoreet, sem et feugiat ultricies, enim tellus faucibus diam, sit amet aliquet augue lorem mattis sem. Aenean aliquam, elit a facilisis sollicitudin, leo leo egestas nulla, sed varius diam velit a orci. Aliquam sollicitudin mi ac quam pharetra dapibus ac quis dui.
</p>
<p>Fusce commodo, nisl adipiscing placerat iaculis, velit mauris imperdiet velit, consequat ornare mi orci in tellus. Mauris auctor aliquet quam eu feugiat. Aliquam blandit lacinia augue, ac accumsan neque malesuada at. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tempor, nibh ac sodales mattis, nisi purus porttitor orci, quis tristique erat ante eu leo. Nunc vulputate aliquet rhoncus. Vestibulum vestibulum augue id velit porttitor tempus. Vestibulum eget augue massa. Fusce tempus dui non arcu porttitor sit amet ultricies sem tempus. Cras at neque eget neque tincidunt iaculis. Sed aliquet elit eu neque venenatis vel blandit eros facilisis. Pellentesque sit amet ipsum id tortor semper iaculis sit amet sed lectus. Cras consequat convallis turpis, vehicula placerat elit venenatis a. Pellentesque consectetur, eros et scelerisque accumsan, magna orci semper magna, in euismod urna tortor eget nibh. Sed lacus nulla, iaculis vel gravida accumsan, porta id nisi. Donec commodo sodales magna sit amet feugiat. Phasellus convallis, neque vitae vulputate viverra, enim magna dictum velit, ut porta elit leo sit amet tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
</p>
<p>Quisque eleifend, leo et posuere mollis, erat odio feugiat mauris, id tincidunt odio sapien vitae enim. Nam ac adipiscing nunc. In hendrerit ipsum eget metus venenatis ac consequat purus tempor. Curabitur lobortis elementum augue at pretium. Quisque sed massa sem, tincidunt laoreet ligula. Suspendisse nunc erat, ultricies sit amet suscipit ut, condimentum ut diam. Proin odio nunc, mollis quis tristique interdum, pretium vitae erat. Sed feugiat varius semper. Quisque pharetra sem auctor quam lacinia molestie. Pellentesque sit amet semper nunc. Proin malesuada, justo ac pulvinar fermentum, ipsum neque laoreet justo, non tempus orci justo in nulla. Phasellus leo quam, luctus sodales viverra sed, congue in sapien.
</p>
<p>Cras sollicitudin, risus vitae suscipit porta, lectus orci pharetra velit, in facilisis nulla massa at velit. Integer posuere massa vitae urna convallis interdum. Proin ullamcorper sapien sit amet odio rhoncus placerat. Fusce iaculis sapien sed ipsum fermentum molestie. Sed eleifend cursus porttitor. Sed ut ullamcorper sapien. Quisque mollis, lectus sit amet hendrerit congue, eros ligula vehicula metus, eget molestie magna velit id diam. Praesent pellentesque, risus a sodales lobortis, sapien ante accumsan quam, sit amet hendrerit ipsum leo id risus. Cras lectus risus, molestie a semper vel, commodo a nisi. Nunc et sapien felis, eu tincidunt felis. Nulla vestibulum odio ut mi bibendum non euismod risus adipiscing. Proin sit amet lectus ligula. Praesent quam lacus, laoreet sed placerat viverra, adipiscing sed justo. Ut nisi dui, malesuada id sodales ac, pellentesque at tortor. Proin pellentesque faucibus nunc, at congue mauris scelerisque eu. Vestibulum iaculis metus sed est lobortis auctor. Phasellus in malesuada nulla. Aliquam erat volutpat. Duis molestie mauris quis elit pellentesque scelerisque. Proin consectetur molestie magna, eu sodales neque feugiat a. 
</p>')

post.categories.new(:name => 'Hardware')
post.categories.new(:name => 'Software')
post.sidebars.new(:title => "Dynamic Content", :content => "<img src=\"http://www.dragonflybsd.org/images/small_logo.png\"/>")
sb = post.sidebars.new(:title => "Projects") #:content => "FOOL: <%= page_uuid %>")
sb.sidebarelements.new(:url => '#', :text => 'tcplay', :place => 5)
sb.sidebarelements.new(:url => '#', :text => 'mrf24j40-driver', :place => 5)
sb.sidebarelements.new(:url => '#', :text => 'sniff802154', :place => 5)
sb.sidebarelements.new(:url => '#', :text => 'sniffSPI', :place => 5)
sb.save
post.save

Post.create(:title => 'The Glue Factory 2', :body => 'Body 2 test')
Post.create(:title => 'The Glue Factory 3', :body => 'Body 3 test')
Post.create(:title => 'The Glue Factory 4', :body => 'Body 4 test')
Post.create(:title => 'The Glue Factory 5', :body => 'Body 5 test')
