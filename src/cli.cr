require "option_parser"
require "./purr.cr"

client_id = ""
server_port = 0

opt_parser = nil
OptionParser.parse! do |parser|
  parser.banner = "Usage: purr --client-id=ID [arguments]"
  parser.on("-p", "--port=PORT", "Specifies port to run server on") { |port| server_port = port.to_i32 }
  parser.on("-i", "--client-id=ID", "Specifies client id to use with Imgur (required)") { |id| client_id = id }
  parser.on("-h", "--help", "Show this help") { puts parser }
  opt_parser = parser
end

if (client_id != "")
  Purr.run_server(server_port, client_id)
else
  puts opt_parser
end
