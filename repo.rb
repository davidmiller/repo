#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'rubygems'

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


    def ignore( pattern )
      # Adds a pattern to the ignore
      puts 'ignoring you'
    end


    def add( file )
      #Adds file(s) to staging
      @@vcs_exists.each do | vcs |      
        add = IO.popen( vcs + " add " + file )
        puts vcs + ':'
        puts add.read    
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

pp ARGV


# Initialise the objects
github = Github::Github.new
repo = Repo::Repository.new

# Set the command line arguments
options = {}
OptionParser.new do | opts |
  opts.banner = "Usage: rgithub [options]"
  
  opts.on( "init", "--init REPO", "Create a repository" ) do | i |
    github.create_repo( i )
    repo.add( '.' )
    repo.commit( 'Initial Commit' )
    repo.push
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

  opts.on( "ignore", "--ignore FILE", "Add the ignore pattern to the .ignore" ) do | n |
    repo.ignore( n )
  end

end.parse!
