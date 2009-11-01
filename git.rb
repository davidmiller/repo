#Some Git class with git api specific calls & stuff

module Git

  class Git::Git
    # Wrapper class for Git


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
  end


end
