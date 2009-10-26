#!/usr/bin/env ruby
require 'net/http'
require 'optparse'
require 'pp'
require 'uri'
require 'rubygems'
require 'json'


class Repository
# Generic VCS repository abstraction class
  
  @@repo_dirs = { 
                  '.git' => 'git'
  }

  @@vcs_exists = Array.new


  def initialize
    # Establishes reops in cwd
    entries = Dir.new( Dir.getwd ).entries
    entries.each do | entry |
      if entry.match( '^[.]' ) and FileTest.directory?( entry )
        if @@repo_dirs.include?( entry )
           @@vcs_exists << @@repo_dirs[entry]
        end
      end
    end
  end


  def commit( msg )
    @@vcs_exists.each do | vcs |      
      commit = IO.popen( vcs + " commit -a -m '" + msg + "'" )
      puts vcs + ':'
      puts commit.read
    end    
  end

end


class Github
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
    create_local_repo()
    set_remote( name )
  end


  def create_github_repo( name )
    # Creates a repository on Github
    api_command = 'json/repos/create'
    homepage = `git config github.homepage`.chomp
    print 'Description for the github repo: '
    description = gets.chomp
    post = { 'name' => name,
             'description' => description,
             'homepage' => homepage }
    access_api( api_command, post )
  end


  def create_local_repo()
    # Creates the local repository
    `git init`
  end


  def set_remote( name )
    # Sets the remote repository to push to
    git_url = "git://github.com/#{@login}/#{name}.git"
    IO.popen( 'git remote add origin ' + git_url )
  end


end


# Set the command line arguments
options = {}
OptionParser.new do | opts |
  opts.banner = "Usage: rgithub [options]"
  
  opts.on( "init", "--init REPO", "Create a repository" ) do | v |
    options[:init] = v
  end

  opts.on( "-r", "--remote", "Remote repo only" ) do | r |
    options[ :remote ] = r
  end

  opts.on( "commit", "--commit MESSAGE", "Commit the repositories" ) do | c |
    options[ :commit ] = c
  end

 end.parse!

#pp options
#pp ARGV

github = Github.new()
repo = Repository.new

if options[:init]
  res = github.create_repo( options[:init] )
#  pp res
end
if options[:commit]
  repo.commit( options[:commit] )
end
