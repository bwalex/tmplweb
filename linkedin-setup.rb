require 'rubygems'
require 'oauth'
require 'json'

# Read current configuration
f = File.open("config/linkedin-config.json", "r")
json = f.read
f.close

# Parse the config into a ruby data structure
config = JSON.parse(json)

# Check whether the config contains the API key and secret
if config['consumer_key'] == '' || config['consumer_secret'] == ''
	puts "You need to get a LinkedIn API key and secret first and save " \
	    "it in the linkedin-config.json file"
	exit 1
end

# If the oauth_token and secret are already set, there's nothing to do
if config['oauth_token'] != '' && config['oauth_secret'] != ''
	puts "Config already contains oauth_token and oauth_secret"
	exit 0
end


# Set up LinkedIn specific OAuth API endpoints
consumer_options = { :site => config['api_host'],
                     :authorize_path => config['authorize_path'],
                     :request_token_path => config['request_token_path'],
                     :access_token_path => config['access_token_path'] }

consumer = OAuth::Consumer.new(config['consumer_key'], config['consumer_secret'],
                               consumer_options)


# Fetch a new access token and secret from the command line
request_token = consumer.get_request_token
puts "Copy and paste the following URL in your browser:"
puts "\t#{request_token.authorize_url}"
puts "When you sign in, copy and paste the oauth verifier here:"
verifier = $stdin.gets.strip
access_token = request_token.get_access_token(:oauth_verifier => verifier)

#puts "Access Token: #{access_token.token}"
#puts "Access Token Secret: #{access_token.secret}"

config['oauth_token'] = access_token.token
config['oauth_secret'] = access_token.secret

f = File.open("config/linkedin-config.json", "w")
f.write JSON.pretty_generate(config)
f.close

puts "Successfully updated configuration"
