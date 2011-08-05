require 'rubygems'
require 'json'
require 'helpers/recursive-openstruct.rb'

class ThemeConfig < RecursiveOpenStruct
end

f= File.open("config/config.json", "r")
config_json = JSON.parse(f.read)
f.close

$config = ThemeConfig.new_recursive(config_json)
