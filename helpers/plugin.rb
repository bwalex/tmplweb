class Plugin
  @registered_plugins = {}

  class << self
    attr_reader :registered_plugins 
  end

  def self.inherited(child)
    Plugin.registered_plugins["#{child.name}"] = child.new
  end

  def expand
    ''
  end

end
