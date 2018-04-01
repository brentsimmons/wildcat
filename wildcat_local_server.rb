# This is useful when you want to run the XML-RPC server locally.
# It doesn’t use SSL. Don’t put this on the public web.
#
# How to run it: cd to this directory, then do
# ruby wildcat_local_server.rb
#
# The code at ./server/wildcat.cgi handles the XML-RPC requests.
# It implements the Blogger and MetaWeblog APIs.

require 'webrick'

server=WEBrick::HTTPServer.new(:Port => 9344, :DocumentRoot => File.join(Dir::pwd, "server/"))
trap("INT"){ server.shutdown }
server.start
