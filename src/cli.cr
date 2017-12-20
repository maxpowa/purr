require "option_parser"
require "./purr.cr"

client_id = ""
server_port = 0

OptionParser.parse! do |parser|
  parser.banner = "Usage: purr [arguments]"
  parser.on("-p", "--port=PORT", "Specifies port to run server on") { |port| server_port = port.to_i32 }
  parser.on("-i", "--client-id=ID", "Specifies client id to use with Imgur") { |id| client_id = id }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

Purr.run_server(server_port, client_id)
