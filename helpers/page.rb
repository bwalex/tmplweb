class Page
  attr_accessor :globalTitle, :title, :content

  def initialize(global_title = '', title = '', content = '')
    @title = title
    @globalTitle = global_title
    @content = content
  end
end
