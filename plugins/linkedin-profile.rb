require 'rubygems'
require 'oauth'
require 'json'
require 'erb'
require 'ostruct'
require 'htmlentities'
require 'helpers/recursive-openstruct.rb'
require 'helpers/plugin.rb'

include ERB::Util

class Profile <RecursiveOpenStruct
  def self.handle_object(object)
    if object.kind_of? String then
      coder = HTMLEntities.new
      coder.encode(object, :named).gsub( "\n", "<br/>" )
    else
      object
    end
  end
end


class LinkedInProfile < Plugin
  def expand
    # Read current configuration
    f = File.open("config/my-linkedin-config.json", "r")
    config = JSON.parse(f.read)
    f.close

      # Check whether the config contains the API key and secret
    if config['consumer_key'] == '' || config['consumer_secret'] == ''
            raise "You need to get a LinkedIn API key and secret first and " \
                "save it in the linkedin-config.json file"
    end

    # If the oauth_token and secret are already set, there's nothing to do
    if config['oauth_token'] == '' && config['oauth_secret'] == ''
            raise "You need to get a LinkedIn oauth token and secret and " \
                "save it in the linkedin-config.json file"
    end

    # Set up LinkedIn specific OAuth API endpoints
    consumer_options = { :site => config['api_host'],
                        :authorize_path => config['authorize_path'],
                        :request_token_path => config['request_token_path'],
                        :access_token_path => config['access_token_path'] }

    consumer = OAuth::Consumer.new(config['consumer_key'], config['consumer_secret'],
                                  consumer_options)

    access_token = OAuth::AccessToken.new(consumer, config['oauth_token'],
                                          config['oauth_secret'])

    # Pick some fields
    fields = ['first-name', 'last-name', 'headline', 'location', 'industry',
              'summary', 'specialties', 'honors', 'publications', 'patents',
              'languages', 'skills', 'educations', 'certifications',
              'picture-url', 'positions'].join(',')
    # Make a request for JSON data"/v1/people/~:(#{fields})"
    json_txt = access_token.get("/v1/people/~:public:(#{fields})",
                                'x-li-format' => 'json').body

    profile = Profile.new_recursive(JSON.parse(json_txt))

    # Open & read template file
    f= File.open("rhtml/profile.rhtml", "r")
    template = f.read
    f.close

    rhtml = ERB.new(template)
    rhtml.result(profile.get_binding)
  end
end
