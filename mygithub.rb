#!/usr/bin/env ruby
require 'net/http'
require 'pp'
require 'uri'
require 'rubygems'
require 'json'

class Github
  # Main class for dealing with the Github v2 api
  @@base_uri = 'http://github.com/api/v2/'


  def initialize
    # Get the login & token variables from the users
    # ~/.gitconfig file
    @login = `git config github.user`.chomp
    @token = `git config github.token`.chomp
  end


  def access_api( api_command )
    # Does the business of wiring the data
    the_uri = @@base_uri + api_command
    resp = Net::HTTP.post_form( URI.parse( the_uri ),
                                { 'login' => @login,
                                  'token' => @token  } )
    return resp.body    
  end


  def get_json( api_command )
    # Make the http request & return json data
    api_command = 'json/' + api_command
    result = JSON.parse( access_api( api_command) )

    if result.has_key? 'Error' 
      raise "Web service error"
    else
      return result
    end

  end

   
  def user_show( user )
    # The public face of listing user data
    api_command = 'user/show/'+ user
    user = get_json( api_command )
    pp user
  end


end


github = Github.new()
github.user_show( 'davidmiller' )
