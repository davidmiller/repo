#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'rubygems'

require 'github'

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
      commit = IO.popen( vcs + " commit -a -m '" + msg + "'" )
      puts vcs + ':'
      puts commit.read
    end    
  end


  def push()
    # Pushes changes to the remote repo
    @@vcs_exists.each do | vcs |
      push = IO.popen( vcs + ' push origin master' )
      puts vcs + ':'
      puts push.read
    end
  end

end


class Git
  # Wrapper class for Git
end


# Initialise the objects

github = Github::Github.new
repo = Repository.new

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

end.parse!


