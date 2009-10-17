#!/usr/bin/env ruby
require 'octopi'
include Octopi

#authenticated do
#  repo = Repository.find(:name => "api-labrat", :user => "fcoury")
#end

user = User.find("davidmiller")
puts "#{user.name} is being followed by #{user.followers.join(", ")} and following #{user.following.join(", ")}"
