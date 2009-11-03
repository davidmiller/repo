#Some Git class with git api specific calls & stuff

module Git

  class Git::Git
    # Wrapper class for Git

   
    def initialize( )
      # Establishes a git environ

      ## This needs to locate the repo itself if false
      @@ignore_file = '.gitignore'
      ##

    end

    
    def climbing_file_find( filename )
      # searches for file climbing dirs
      cwd = Dir::getwd
      if Dir::glob( filename )
        return Dir::glob( filename )[0]
      else
        if Dir::getwd == '/'
          return False
        else
          Dir::chdir( '..' )
          recurse = climbing_file_find( filename )
          Dir chdir( cwd )
          return recurse[0]
        end
      end
    end


    def init( ignore_pattern = false )
      #Initializes a Git repository      
      `git init`
      `touch .gitignore`
      if ignore_pattern
        ignore( ignore_pattern )
      end
    end


    def add( file )
      #Adds file(s) to staging
        add = IO.popen( "git add " + file )
        puts 'Git:'
        puts add.read    
    end


    def ignore( pattern )
      #Adds a pattern to the .gitignore file
      if open( @@ignore_file ).grep( Regexp.compile( pattern ) ).size == 0
        File.open( @@ignore_file, 'a' ) { | f | f.puts( pattern ) }
      end
    end


    def commit( msg )
      # Commits the repository(s)
        commit = IO.popen( "git commit -a -m '" + msg + "'" )
        puts 'Git:'
        puts commit.read
    end


    def push()
        push = IO.popen( 'git push origin master' )
        puts 'Git:'
        puts push.read
    end

    def status
        # Gets the status of the git repo
        status = IO.popen( 'git status' )
        puts 'Git:'
        puts status.read
    end


  end


end
