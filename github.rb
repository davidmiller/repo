require 'net/http'
require 'rubygems'
require 'uri'
require 'json'

module Github

class Github::Github
  # Main class for dealing with the Github v2 api
  @@base_uri = 'http://github.com/api/v2/'


  def initialize
    # Get the login & token variables from the users
    # ~/.gitconfig file
    @login = `git config github.user`.chomp
    @token = `git config github.token`.chomp
  end


  def access_api( api_command, post = false )
    # Does the business of wiring the data
    the_uri = @@base_uri + api_command    
    
    the_post = { 'login' => @login,
                 'token' => @token  }

    if post
      the_post.merge!( post )
    end

    resp = Net::HTTP.post_form( URI.parse( the_uri ), the_post )
    
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


  def create_repo( name )
    # Create the repo structure
    create_github_repo( name )
    set_remote( name )
  end


  def create_github_repo( name )
    # Creates a repository on Github
    api_command = 'json/repos/create'
    homepage = `git config github.homepage`.chomp
    puts 'Description for the github repo: '
    description = gets()

    post = { 'name' => name,
             'description' => description,
             'homepage' => homepage }
    access_api( api_command, post )
  end


  def set_remote( name )
    # Sets the remote repository to push to
    git_url = "git@github.com:#{@login}/#{name}.git"
    IO.popen( 'git remote add origin ' + git_url )
  end

  end

end
