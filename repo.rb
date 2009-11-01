#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'rubygems'
if File.ftype(  __FILE__ ) == 'link'
  __file__ = File.readlink( __FILE__ )
else
  __file__ = __FILE__
end
#puts File.dirname(__file__)
$: << File.expand_path( File.dirname( __file__ ) )
#puts $:
require 'github'
require 'git'

module Repo

  class Repo::Repository
    # Generic VCS repository abstraction class
    
    @@repo_dirs = { 
                   '.git' => Git::Git
                  }

    @@vcs_exists = Array.new
  

    def initialize
      # Establishes reops in cwd
      entries = Dir.new( Dir.getwd ).entries
      entries.each do | entry |
        if entry.match( '^[.]' ) and FileTest.directory?( entry )
          if @@repo_dirs.include?( entry )
            @@vcs_exists << @@repo_dirs[entry].new
          end
        end
      end
    end


    def init()
      #Initializes a repository
      @@vcs_exists.each do | vcs |      
       vcs.init
      end
    end


    def ignore( pattern )
      # Adds a pattern to the ignore
      @@vcs_exists.each do | vcs |      
       vcs.ignore( pattern )
      end
    end


    def add( file )
      #Adds file(s) to staging
      @@vcs_exists.each do | vcs |      
       vcs.add( file )
      end
    end
    
    
    def commit( msg )
      # Commits the repository(s)
      @@vcs_exists.each do | vcs |      
        vcs.commit( msg )
      end    
    end
    

    def push()
      # Pushes changes to the remote repo
      @@vcs_exists.each do | vcs |
        vcs.push
      end
    end
    
  end

end

# Irritating ARGV parsing
subcommands = [
               'push',
               'init',
               'add',
               'commit',
               'ignore'
              ]
ARGV = ARGV.map do | opt |
  if subcommands.include?( opt )
    "--#{opt}"
  else
    opt
  end
end

#pp ARGV

# Initialise the objects
github = Github::Github.new
repo = Repo::Repository.new

# Set the command line arguments
options = {}
OptionParser.new do | opts |
  opts.banner = "Usage: rgithub [options]"

 
  opts.on( "init", "--init REPO", "Create a repository" ) do | i |
    github.create_repo( i )
    repo init
    repo.add( '.' )
    repo.commit( 'Initial Commit' )
    repo.push
  end

 opts.on( "ignore", "--ignore FILE", "Add the ignore pattern to the .ignore" ) do | n |
    repo.ignore( n )
  end

  opts.on( "commit", "--commit MESSAGE", "Commit the repositories" ) do | c |
    repo.commit( c )
  end
  
  opts.on( "push", "--push", "Push local changes to the remote repo" ) do | p |
    repo.push
  end
  
  opts.on( "add", "--add ADD", "Add file(s) to repo" ) do | a |
    repo.add( a )
  end

end.parse!
